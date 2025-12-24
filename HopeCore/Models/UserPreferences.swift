//
//  UserPreferences.swift
//  HopeCore
//
//  Data Model - User Settings and Preferences
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Stores all user customization: notifications, categories, subscription
//  - Free users: max 5 messages/day, 1 demotivation per 5 messages
//  - Premium users: up to 20 messages/day, demotivation optional
//  - Notification schedule determines when messages are delivered
//  - All data stored locally (no authentication required per spec)
//

import Foundation
import SwiftData

/// User preferences and settings
/// Single source of truth for user customization
@Model
final class UserPreferences {
    /// Unique identifier (should only be one instance)
    var id: UUID

    // MARK: - Subscription

    /// Subscription tier: "free" or "premium"
    var subscriptionTier: String

    /// Subscription expiry date (nil for free users)
    var subscriptionExpiryDate: Date?

    // MARK: - Notification Settings

    /// Number of messages per day (1-5 for free, 1-20 for premium)
    var messagesPerDay: Int

    /// Start time for notification window
    var notificationStartTime: Date

    /// End time for notification window
    var notificationEndTime: Date

    /// Whether quiet hours are enabled
    var quietHoursEnabled: Bool

    /// Quiet hours start time
    var quietHoursStart: Date?

    /// Quiet hours end time
    var quietHoursEnd: Date?

    /// Whether notifications have sound
    var notificationSoundEnabled: Bool

    /// Whether notifications have haptic feedback
    var notificationHapticEnabled: Bool

    // MARK: - Message Preferences

    /// Selected category IDs (empty = all categories)
    /// AGENT NOTE: Free users get all; premium can filter
    var selectedCategoryIDs: [UUID]

    /// Whether demotivation messages are enabled
    /// Auto-disabled for premium users per spec
    var demotivationEnabled: Bool

    /// Counter for demotivation message timing (free users)
    /// Increments with each message; demotivation sent every 5th
    var demotivationCounter: Int

    // MARK: - Onboarding

    /// Whether user has completed onboarding
    var hasCompletedOnboarding: Bool

    /// User's selected situation (from onboarding)
    var userSituation: String?

    /// Areas of life user is rebuilding (from onboarding)
    var rebuildingAreas: [String]

    /// Default background image for textOverlay quotes (e.g., "image-1", "image-2", "image-3")
    /// Selected during onboarding, can be changed in settings
    var defaultBackgroundImage: String?

    /// Selected font ID for message display (e.g., "avenir", "georgia", "palatino")
    /// Selected during onboarding, can be changed in settings
    var selectedFontID: String?

    // MARK: - Widget Settings

    /// Whether lock screen widget is enabled
    var lockScreenWidgetEnabled: Bool

    /// Whether home screen widget is enabled
    var homeScreenWidgetEnabled: Bool

    /// Widget size preference: "small", "medium", "large"
    var widgetSizePreference: String

    // MARK: - App State

    /// Last time user opened the app
    var lastAppOpenedAt: Date

    /// Total number of messages viewed
    var totalMessagesViewed: Int

    /// Total number of audio sessions completed
    var totalAudioSessions: Int

    /// Date user first installed/used app
    var firstUsedAt: Date

    init(
        id: UUID = UUID(),
        subscriptionTier: String = "free",
        subscriptionExpiryDate: Date? = nil,
        messagesPerDay: Int = 3,
        notificationStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        notificationEndTime: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date(),
        quietHoursEnabled: Bool = false,
        quietHoursStart: Date? = nil,
        quietHoursEnd: Date? = nil,
        notificationSoundEnabled: Bool = true,
        notificationHapticEnabled: Bool = true,
        selectedCategoryIDs: [UUID] = [],
        demotivationEnabled: Bool = true, // Enabled by default for free users
        demotivationCounter: Int = 0,
        hasCompletedOnboarding: Bool = false,
        userSituation: String? = nil,
        rebuildingAreas: [String] = [],
        defaultBackgroundImage: String? = nil,
        selectedFontID: String? = nil,
        lockScreenWidgetEnabled: Bool = true,
        homeScreenWidgetEnabled: Bool = false,
        widgetSizePreference: String = "medium",
        lastAppOpenedAt: Date = Date(),
        totalMessagesViewed: Int = 0,
        totalAudioSessions: Int = 0,
        firstUsedAt: Date = Date()
    ) {
        self.id = id
        self.subscriptionTier = subscriptionTier
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.messagesPerDay = messagesPerDay
        self.notificationStartTime = notificationStartTime
        self.notificationEndTime = notificationEndTime
        self.quietHoursEnabled = quietHoursEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.notificationSoundEnabled = notificationSoundEnabled
        self.notificationHapticEnabled = notificationHapticEnabled
        self.selectedCategoryIDs = selectedCategoryIDs
        self.demotivationEnabled = demotivationEnabled
        self.demotivationCounter = demotivationCounter
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.userSituation = userSituation
        self.rebuildingAreas = rebuildingAreas
        self.defaultBackgroundImage = defaultBackgroundImage
        self.selectedFontID = selectedFontID
        self.lockScreenWidgetEnabled = lockScreenWidgetEnabled
        self.homeScreenWidgetEnabled = homeScreenWidgetEnabled
        self.widgetSizePreference = widgetSizePreference
        self.lastAppOpenedAt = lastAppOpenedAt
        self.totalMessagesViewed = totalMessagesViewed
        self.totalAudioSessions = totalAudioSessions
        self.firstUsedAt = firstUsedAt
    }
}

// MARK: - Subscription Tier Enum
enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case premium = "premium"

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .premium:
            return "Premium"
        }
    }

    var maxMessagesPerDay: Int {
        switch self {
        case .free:
            return 5
        case .premium:
            return 20
        }
    }

    var hasDemotivationMessages: Bool {
        switch self {
        case .free:
            return true // 1 per 5 messages
        case .premium:
            return false // Optional, disabled by default
        }
    }

    var widgetUpdateFrequency: String {
        switch self {
        case .free:
            return "Once daily"
        case .premium:
            return "Matches notification schedule"
        }
    }
}

// MARK: - Computed Properties
extension UserPreferences {
    /// Current subscription tier as enum
    var tier: SubscriptionTier {
        return SubscriptionTier(rawValue: subscriptionTier) ?? .free
    }

    /// Whether user is currently subscribed to premium
    var isPremium: Bool {
        guard tier == .premium else { return false }

        if let expiryDate = subscriptionExpiryDate {
            return expiryDate > Date()
        }

        return false
    }

    /// Whether a demotivation message should be sent next
    /// (Free users only: every 5th message)
    var shouldSendDemotivation: Bool {
        guard !isPremium && demotivationEnabled else { return false }
        return demotivationCounter >= 5
    }

    /// Whether user can receive more messages today
    /// AGENT NOTE: Implement daily limit checking in NotificationManager
    func canSendMoreMessagesToday(currentCount: Int) -> Bool {
        return currentCount < tier.maxMessagesPerDay
    }
}
