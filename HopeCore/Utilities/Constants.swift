//
//  Constants.swift
//  HopeCore
//
//  Utilities - App-wide Constants
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Centralized constants for configuration
//  - R2 Cloudflare endpoints for images and audio
//  - App limits and defaults
//  - Notification identifiers
//  - Widget configuration
//

import Foundation

/// App-wide constants and configuration
enum Constants {

    // MARK: - App Information
    enum App {
        static let name = "HopeCore"
        static let bundleIdentifier = "com.hopecore.app"
        static let version = "1.0.0"
        static let buildNumber = "1"
    }

    // MARK: - Backend Configuration
    enum Backend {
        /// R2 Cloudflare base URL for images
        /// AGENT NOTE: Update with actual R2 bucket URL
        static let imageBaseURL = "https://pub-0017d537075f47dba685fa2a8ebf5591.r2.dev"

        /// R2 Cloudflare base URL for audio
        /// AGENT NOTE: Update with actual R2 bucket URL
        static let audioBaseURL = "https://r2.example.com/audio"

        /// API base URL (future)
        /// AGENT NOTE: For content management system integration
        static let apiBaseURL = "https://api.hopecore.com/v1"
    }

    // MARK: - Message Limits
    enum Messages {
        /// Free tier daily limit
        static let freeDailyLimit = 5

        /// Premium tier daily limit
        static let premiumDailyLimit = 20

        /// Demotivation message frequency (1 per X messages for free users)
        static let demotivationFrequency = 5

        /// Number of messages to pre-load daily
        static let dailyPreloadCount = 3

        /// Number of recent messages to exclude from rotation
        static let rotationExclusionCount = 10
    }

    // MARK: - Audio Configuration
    enum Audio {
        /// Sleep sound typical duration (seconds)
        static let sleepDurationMin = 600  // 10 min
        static let sleepDurationMax = 900  // 15 min

        /// Focus session typical duration (seconds)
        static let focusDurationMin = 300   // 5 min
        static let focusDurationMax = 1800  // 30 min

        /// Default playback rate
        static let defaultPlaybackRate: Float = 1.0

        /// Available playback rates
        static let availablePlaybackRates: [Float] = [1.0, 1.25, 1.5, 2.0]

        /// Default volume
        static let defaultVolume: Float = 1.0
    }

    // MARK: - Notification Configuration
    enum Notifications {
        /// Notification category identifier
        static let categoryIdentifier = "HOPECORE_MESSAGE"

        /// Notification action identifiers
        static let saveActionIdentifier = "SAVE_MESSAGE"
        static let shareActionIdentifier = "SHARE_MESSAGE"
        static let dismissActionIdentifier = "DISMISS_MESSAGE"

        /// Default notification sound
        static let defaultSoundName = "default"

        /// Notification title
        static let notificationTitle = "Your Daily Inspiration"
    }

    // MARK: - Widget Configuration
    enum Widgets {
        /// Lock screen widget identifier
        static let lockScreenWidgetID = "com.hopecore.widget.lockscreen"

        /// Home screen widget identifier
        static let homeScreenWidgetID = "com.hopecore.widget.homescreen"

        /// Widget update interval for free users (seconds)
        static let freeUpdateInterval: TimeInterval = 86400 // 24 hours

        /// Widget update interval for premium users (matches notification schedule)
        static let premiumUpdateInterval: TimeInterval = 7200 // 2 hours
    }

    // MARK: - Cache Configuration
    enum Cache {
        /// Maximum disk cache size (bytes)
        static let maxDiskCacheSize = 100 * 1024 * 1024 // 100 MB

        /// Maximum memory cache size (bytes)
        static let maxMemoryCacheSize = 50 * 1024 * 1024 // 50 MB

        /// Image compression quality
        static let imageCompressionQuality: CGFloat = 0.8

        /// Cache cleanup threshold
        static let cleanupThreshold: Double = 0.8 // Cleanup when 80% full
    }

    // MARK: - Default User Preferences
    enum Defaults {
        /// Default messages per day
        static let messagesPerDay = 3

        /// Default notification start time (9:00 AM)
        static let notificationStartHour = 9
        static let notificationStartMinute = 0

        /// Default notification end time (9:00 PM)
        static let notificationEndHour = 21
        static let notificationEndMinute = 0

        /// Default quiet hours enabled
        static let quietHoursEnabled = false

        /// Default notification sound enabled
        static let notificationSoundEnabled = true

        /// Default haptic feedback enabled
        static let hapticFeedbackEnabled = true

        /// Default widget size
        static let widgetSize = "medium"
    }

    // MARK: - UI Configuration
    enum UI {
        /// Message grid columns
        static let messageGridColumns = 2

        /// Message thumbnail aspect ratio
        static let thumbnailAspectRatio: CGFloat = 4/3

        /// Max message image height (full screen)
        static let maxMessageImageHeight: CGFloat = 300

        /// Card animation duration
        static let cardAnimationDuration: TimeInterval = 0.3

        /// Button animation duration
        static let buttonAnimationDuration: TimeInterval = 0.2

        /// Standard corner radius
        static let cornerRadius: CGFloat = 16

        /// Small corner radius
        static let smallCornerRadius: CGFloat = 12
    }

    // MARK: - Debug Configuration
    enum Debug {
        /// Enable debug logging
        static let loggingEnabled = true

        /// Enable verbose logging
        static let verboseLogging = false

        /// Use sample data instead of backend
        static let useSampleData = true // AGENT NOTE: Set to false when backend is ready
    }

    // MARK: - Subscription Configuration
    enum Subscription {
        /// Monthly price (display only)
        static let monthlyPrice = "$4.99"

        /// Yearly price (display only)
        static let yearlyPrice = "$39.99"

        /// Lifetime price (display only)
        static let lifetimePrice = "$99.99"

        /// Free trial days (if applicable)
        static let freeTrialDays = 7
    }
}
