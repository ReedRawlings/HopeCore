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
    /// AGENT NOTE: This runs in the background to pre-load 3 random images
    private func handleImagePrefetchTask(task: BGAppRefreshTask) {
        print("🔄 Background image prefetch task started")

        // Schedule next occurrence
        scheduleDailyImagePrefetch()

        // Set expiration handler
        task.expirationHandler = {
            print("⏰ Background task expired before completion")
            task.setTaskCompleted(success: false)
        }

        // Perform image prefetch
        Task {
            do {
                // Create model context for background operation
                let modelContainer = try ModelContainer(for: Message.self, UserPreferences.self)
                let modelContext = ModelContext(modelContainer)

                // Fetch all messages
                let descriptor = FetchDescriptor<Message>()
                let messages = try modelContext.fetch(descriptor)

                // Pre-load 3 random images via ImageCacheManager
                await ImageCacheManager.shared.preloadDailyImages(from: messages)

                // Clean up old cache if needed
                ImageCacheManager.shared.cleanupOldCacheIfNeeded()

                print("✅ Background image prefetch completed successfully")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ Background task failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
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
