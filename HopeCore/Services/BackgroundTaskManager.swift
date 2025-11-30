//
//  BackgroundTaskManager.swift
//  HopeCore
//
//  Service - Background Task Management
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages background tasks for daily image pre-loading
//  - Pre-loads 3 random message images each morning per spec
//  - Updates Lock Screen widget with new featured message
//  - Uses BGTaskScheduler for reliable background execution
//  - Respects system resource constraints
//  - Cleans up old cache automatically
//
//  IMPLEMENTATION REQUIREMENTS:
//  1. Add "Permitted background task scheduler identifiers" to Info.plist
//     Key: BGTaskSchedulerPermittedIdentifiers
//     Value: Array with "com.hopecore.prefetch-images"
//  2. Register task handler in app launch (HopeCoreApp.swift)
//  3. Schedule task after onboarding and when app enters background
//

import Foundation
import BackgroundTasks
import SwiftData
import WidgetKit

/// Manages background tasks for the app
/// Primarily handles daily image pre-loading for smooth UX
@Observable
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    /// Background task identifier
    /// AGENT NOTE: Must be added to Info.plist BGTaskSchedulerPermittedIdentifiers
    static let imagePrefetchTaskIdentifier = "com.hopecore.prefetch-images"

    private init() {}

    // MARK: - Registration

    /// Register background task handlers
    /// AGENT NOTE: Call this in app launch (HopeCoreApp.init or applicationDidFinishLaunching)
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.imagePrefetchTaskIdentifier,
            using: nil
        ) { task in
            self.handleImagePrefetchTask(task: task as! BGAppRefreshTask)
        }

        print("✅ Background tasks registered")
    }

    // MARK: - Scheduling

    /// Schedule daily image pre-fetch task
    /// AGENT NOTE: Schedule this after onboarding and when app enters background
    func scheduleDailyImagePrefetch() {
        let request = BGAppRefreshTaskRequest(identifier: Self.imagePrefetchTaskIdentifier)

        // Schedule for next morning (6 AM)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.hour = 6
        components.minute = 0

        if let nextMorning = calendar.date(from: components) {
            // If 6 AM has passed today, schedule for tomorrow
            let scheduledDate = nextMorning < Date() ? calendar.date(byAdding: .day, value: 1, to: nextMorning)! : nextMorning
            request.earliestBeginDate = scheduledDate
        } else {
            // Fallback: 12 hours from now
            request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60)
        }

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Daily image prefetch scheduled for: \(request.earliestBeginDate?.description ?? "unknown")")
        } catch {
            print("❌ Failed to schedule background task: \(error.localizedDescription)")
        }
    }

    // MARK: - Task Handlers

    /// Handle image prefetch background task
    /// AGENT NOTE: This runs in the background to:
    /// 1. Pre-load 3 random images for smooth UX
    /// 2. Update today's featured message
    /// 3. Refresh the Lock Screen widget with new message
    private func handleImagePrefetchTask(task: BGAppRefreshTask) {
        print("🔄 Background task started: image prefetch + widget update")

        // Schedule next occurrence
        scheduleDailyImagePrefetch()

        // Set expiration handler
        task.expirationHandler = {
            print("⏰ Background task expired before completion")
            task.setTaskCompleted(success: false)
        }

        // Perform image prefetch and widget update
        Task {
            do {
                // Create model context for background operation
                let modelContainer = try ModelContainer(for: Message.self, UserPreferences.self, RotationState.self)
                let modelContext = ModelContext(modelContainer)

                // Fetch all messages
                let messageDescriptor = FetchDescriptor<Message>()
                let messages = try modelContext.fetch(messageDescriptor)

                // Fetch user preferences
                let prefsDescriptor = FetchDescriptor<UserPreferences>()
                let preferences = try modelContext.fetch(prefsDescriptor)
                let userPrefs = preferences.first ?? UserPreferences()

                // Pre-load 3 random images via ImageCacheManager
                await ImageCacheManager.shared.preloadDailyImages(from: messages)

                // Clean up old cache if needed
                ImageCacheManager.shared.cleanupOldCacheIfNeeded()

                // Update featured message and widget
                // AGENT NOTE: This ensures widget has fresh content each morning
                updateWidgetInBackground(messages: messages, preferences: userPrefs, modelContext: modelContext)

                print("✅ Background task completed: images prefetched, widget updated")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Background task failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    /// Update widget with a fresh message in background
    /// Selects a new featured message and saves to WidgetDataStore
    private func updateWidgetInBackground(messages: [Message], preferences: UserPreferences, modelContext: ModelContext) {
        // Filter out demotivation messages
        let eligibleMessages = messages.filter { !$0.isDemotivation }
        
        guard !eligibleMessages.isEmpty else {
            print("⚠️ No eligible messages for widget")
            return
        }
        
        // Get messages sorted by last shown (oldest first) to avoid repetition
        let sorted = eligibleMessages.sorted { msg1, msg2 in
            let date1 = msg1.lastShownAt ?? Date.distantPast
            let date2 = msg2.lastShownAt ?? Date.distantPast
            return date1 < date2
        }
        
        // Pick from the least recently shown messages
        let excludeRecent = min(5, sorted.count - 1)
        let available = Array(sorted.prefix(sorted.count - max(0, excludeRecent)))
        
        guard let selectedMessage = available.randomElement() else {
            print("⚠️ Could not select message for widget")
            return
        }
        
        // Update message tracking
        selectedMessage.lastShownAt = Date()
        selectedMessage.shownCount += 1
        try? modelContext.save()
        
        // Save to widget data store
        WidgetDataStore.saveTodaysMessage(
            id: selectedMessage.id,
            text: selectedMessage.text,
            categoryName: selectedMessage.categoryName
        )
        
        // Update premium status
        WidgetDataStore.updatePremiumStatus(preferences.isPremium)
        
        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "HopeCoreWidget")
        
        print("🔮 Widget updated with message: \(selectedMessage.text.prefix(40))...")
    }

    // MARK: - Manual Execution (for testing)

    /// Manually trigger image prefetch for testing
    /// AGENT NOTE: Use this during development to test without waiting for background scheduler
    func manuallyPrefetchImages(modelContext: ModelContext) async {
        do {
            // Fetch all messages
            let descriptor = FetchDescriptor<Message>()
            let messages = try modelContext.fetch(descriptor)

            // Pre-load 3 random images
            await ImageCacheManager.shared.preloadDailyImages(from: messages)

            // Clean up old cache
            ImageCacheManager.shared.cleanupOldCacheIfNeeded()

            print("✅ Manual image prefetch completed")
        } catch {
            print("❌ Manual prefetch failed: \(error.localizedDescription)")
        }
    }
}
