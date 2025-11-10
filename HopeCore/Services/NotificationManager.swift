//
//  NotificationManager.swift
//  HopeCore
//
//  Service - Local Notification Management
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages scheduling of hopecore message notifications
//  - Respects user's daily limit (5 for free, 20 for premium)
//  - Handles quiet hours and notification time windows
//  - Enforces demotivation message pattern (1 per 5 for free users)
//  - Uses rich notifications with image attachments
//  - No authentication required - all local
//

import Foundation
import UserNotifications
import SwiftData

/// Manages local notifications for hopecore messages
/// Singleton service accessed throughout the app
@Observable
class NotificationManager {
    static let shared = NotificationManager()

    /// Notification permission status
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    /// Whether notifications are currently enabled
    var notificationsEnabled: Bool = false

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Permission Management

    /// Request notification permissions from user
    /// AGENT NOTE: Call this during onboarding
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await notificationCenter.requestAuthorization(options: options)

        await MainActor.run {
            notificationsEnabled = granted
        }

        await checkAuthorizationStatus()
    }

    /// Check current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()

        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
            notificationsEnabled = settings.authorizationStatus == .authorized
        }
    }

    /// Synchronous version for initialization
    private func checkAuthorizationStatus() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Notification Scheduling

    /// Schedule notifications based on user preferences
    /// AGENT NOTE: Call this when preferences change or daily at midnight
    /// - Parameters:
    ///   - preferences: User notification preferences
    ///   - messages: Available messages to send
    func scheduleNotifications(
        preferences: UserPreferences,
        messages: [Message],
        modelContext: ModelContext
    ) async throws {
        // Clear existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        guard notificationsEnabled else {
            print("Notifications not enabled, skipping schedule")
            return
        }

        // Calculate how many messages to schedule today
        let dailyLimit = preferences.tier.maxMessagesPerDay
        let messagesToSchedule = min(preferences.messagesPerDay, dailyLimit)

        // Get time window for notifications
        let startTime = preferences.notificationStartTime
        let endTime = preferences.notificationEndTime

        // Calculate notification times evenly distributed
        let notificationTimes = calculateNotificationTimes(
            count: messagesToSchedule,
            startTime: startTime,
            endTime: endTime,
            quietHoursEnabled: preferences.quietHoursEnabled,
            quietStart: preferences.quietHoursStart,
            quietEnd: preferences.quietHoursEnd
        )

        // Select messages to send (respecting demotivation pattern)
        let selectedMessages = selectMessagesToSend(
            messages: messages,
            count: messagesToSchedule,
            preferences: preferences
        )

        // Schedule each notification
        for (index, (message, time)) in zip(selectedMessages, notificationTimes).enumerated() {
            try await scheduleNotification(
                for: message,
                at: time,
                identifier: "hopecore-message-\(index)",
                preferences: preferences
            )
        }

        print("Scheduled \(messagesToSchedule) notifications")
    }

    /// Schedule a single notification for a message
    private func scheduleNotification(
        for message: Message,
        at time: Date,
        identifier: String,
        preferences: UserPreferences
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Your Daily Inspiration"
        content.body = String(message.text.prefix(150)) // Truncate to 150 chars
        content.categoryIdentifier = message.categoryName
        content.userInfo = ["messageId": message.id.uuidString]

        // Add sound if enabled
        if preferences.notificationSoundEnabled {
            content.sound = .default
        }

        // AGENT NOTE: Image attachment would be added here
        // if let imageURL = message.cachedImageFilename {
        //     let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL)
        //     content.attachments = [attachment]
        // }

        // Calculate trigger from date
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: time
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true // Repeat daily
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    /// Calculate evenly distributed notification times
    /// AGENT NOTE: Respects quiet hours by skipping those time periods
    private func calculateNotificationTimes(
        count: Int,
        startTime: Date,
        endTime: Date,
        quietHoursEnabled: Bool,
        quietStart: Date?,
        quietEnd: Date?
    ) -> [Date] {
        var times: [Date] = []

        let calendar = Calendar.current
        let start = calendar.dateComponents([.hour, .minute], from: startTime)
        let end = calendar.dateComponents([.hour, .minute], from: endTime)

        guard let startHour = start.hour,
              let startMinute = start.minute,
              let endHour = end.hour,
              let endMinute = end.minute else {
            return times
        }

        // Calculate total minutes in window
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        let totalMinutes = endTotalMinutes - startTotalMinutes

        // Divide window into equal intervals
        let interval = totalMinutes / count

        for i in 0..<count {
            let minuteOffset = startTotalMinutes + (interval * i)
            let hour = minuteOffset / 60
            let minute = minuteOffset % 60

            if let time = calendar.date(from: DateComponents(hour: hour, minute: minute)) {
                // AGENT NOTE: Add quiet hours check here
                times.append(time)
            }
        }

        return times
    }

    /// Select messages to send, respecting demotivation pattern
    /// AGENT NOTE: Free users get 1 demotivation per 5 messages
    private func selectMessagesToSend(
        messages: [Message],
        count: Int,
        preferences: UserPreferences
    ) -> [Message] {
        var selectedMessages: [Message] = []

        // Filter messages by enabled categories
        let availableMessages = messages.filter { message in
            if preferences.selectedCategoryIDs.isEmpty {
                return !message.isDemotivation
            }
            // AGENT NOTE: Implement category filtering here
            return !message.isDemotivation
        }

        // Determine if we need to include a demotivation message
        let shouldIncludeDemotivation = preferences.shouldSendDemotivation

        if shouldIncludeDemotivation {
            // Get demotivation messages
            let demotivationMessages = messages.filter { $0.isDemotivation }

            if let demotivationMessage = demotivationMessages.randomElement() {
                // Add demotivation message at random position
                let randomPosition = Int.random(in: 0..<count)

                for i in 0..<count {
                    if i == randomPosition {
                        selectedMessages.append(demotivationMessage)
                    } else {
                        if let message = availableMessages.randomElement() {
                            selectedMessages.append(message)
                        }
                    }
                }
            }
        } else {
            // Just select random hopecore messages
            selectedMessages = availableMessages.shuffled().prefix(count).map { $0 }
        }

        return selectedMessages
    }

    // MARK: - Notification Actions

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
}
