//
//  SubscriptionTier.swift
//  HopeCore
//
//  Data Model - Subscription Information
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Free: max 5 messages/day, demotivation mandatory (1 per 5)
//  - Premium: up to 20 messages/day, no demotivation (optional toggle)
//  - Premium also gets widget updates matching notification schedule
//  - Subscription managed via Apple In-App Purchase (future implementation)
//

import Foundation

/// Subscription tier information and features
/// Used for display in settings and onboarding
struct SubscriptionInfo {
    let tier: SubscriptionTier
    let features: [FeatureInfo]
    let priceMonthly: String? // e.g., "$4.99"
    let priceYearly: String? // e.g., "$39.99"
}

/// Individual feature with availability by tier
struct FeatureInfo {
    let name: String
    let description: String
    let availableInFree: Bool
    let availableInPremium: Bool
    let iconName: String
}

// MARK: - Subscription Features
extension SubscriptionInfo {
    /// Free tier features
    static let freeTier = SubscriptionInfo(
        tier: .free,
        features: [
            FeatureInfo(
                name: "Daily Messages",
                description: "Up to 5 hopecore messages per day",
                availableInFree: true,
                availableInPremium: true,
                iconName: "message.fill"
            ),
            FeatureInfo(
                name: "Message Categories",
                description: "All resilience, agency, rebuilding, possibility content",
                availableInFree: true,
                availableInPremium: true,
                iconName: "folder.fill"
            ),
            FeatureInfo(
                name: "Demotivation Messages",
                description: "1 challenging message per 5 messages (mandatory)",
                availableInFree: true,
                availableInPremium: false,
                iconName: "exclamationmark.triangle.fill"
            ),
            FeatureInfo(
                name: "Audio Library",
                description: "Sleep sounds and focus sessions",
                availableInFree: true,
                availableInPremium: true,
                iconName: "speaker.wave.2.fill"
            ),
            FeatureInfo(
                name: "Save Messages",
                description: "Bookmark favorite messages",
                availableInFree: true,
                availableInPremium: true,
                iconName: "heart.fill"
            ),
            FeatureInfo(
                name: "Lock Screen Widget",
                description: "Daily message on lock screen (updates once daily)",
                availableInFree: true,
                availableInPremium: true,
                iconName: "lock.fill"
            )
        ],
        priceMonthly: nil,
        priceYearly: nil
    )

    /// Premium tier features
    /// AGENT NOTE: Pricing TBD - implement via StoreKit
    static let premiumTier = SubscriptionInfo(
        tier: .premium,
        features: [
            FeatureInfo(
                name: "Unlimited Messages",
                description: "Up to 20 hopecore messages per day",
                availableInFree: false,
                availableInPremium: true,
                iconName: "message.badge.fill"
            ),
            FeatureInfo(
                name: "No Demotivation (Default)",
                description: "Challenging messages disabled by default (can enable)",
                availableInFree: false,
                availableInPremium: true,
                iconName: "checkmark.shield.fill"
            ),
            FeatureInfo(
                name: "Custom Notification Schedule",
                description: "Full control over timing and frequency",
                availableInFree: false,
                availableInPremium: true,
                iconName: "clock.fill"
            ),
            FeatureInfo(
                name: "Category Filtering",
                description: "Choose exactly which categories to receive",
                availableInFree: false,
                availableInPremium: true,
                iconName: "line.3.horizontal.decrease.circle.fill"
            ),
            FeatureInfo(
                name: "Priority Widget Updates",
                description: "Widget refreshes match your notification schedule",
                availableInFree: false,
                availableInPremium: true,
                iconName: "arrow.clockwise.circle.fill"
            ),
            FeatureInfo(
                name: "Offline Audio",
                description: "Download audio for offline listening",
                availableInFree: false,
                availableInPremium: true,
                iconName: "arrow.down.circle.fill"
            ),
            FeatureInfo(
                name: "All Audio Content",
                description: "Access to premium sleep and focus sessions",
                availableInFree: false,
                availableInPremium: true,
                iconName: "music.note.list"
            ),
            FeatureInfo(
                name: "Early Access",
                description: "New messages and features before free users",
                availableInFree: false,
                availableInPremium: true,
                iconName: "star.fill"
            )
        ],
        priceMonthly: "$4.99", // AGENT NOTE: Placeholder - update with actual pricing
        priceYearly: "$39.99"  // AGENT NOTE: Placeholder - update with actual pricing
    )

    /// Get subscription info for a specific tier
    static func info(for tier: SubscriptionTier) -> SubscriptionInfo {
        switch tier {
        case .free:
            return freeTier
        case .premium:
            return premiumTier
        }
    }

    /// Compare features between tiers
    static func premiumOnlyFeatures() -> [FeatureInfo] {
        return premiumTier.features.filter { !$0.availableInFree }
    }
}

// MARK: - In-App Purchase Product IDs
/// StoreKit product identifiers
/// AGENT NOTE: Configure these in App Store Connect
enum IAPProductID: String {
    case premiumMonthly = "com.hopecore.premium.monthly"
    case premiumYearly = "com.hopecore.premium.yearly"
    case premiumLifetime = "com.hopecore.premium.lifetime"

    var displayName: String {
        switch self {
        case .premiumMonthly:
            return "Premium Monthly"
        case .premiumYearly:
            return "Premium Yearly"
        case .premiumLifetime:
            return "Premium Lifetime"
        }
    }

    var description: String {
        switch self {
        case .premiumMonthly:
            return "Full access, billed monthly"
        case .premiumYearly:
            return "Full access, billed annually (save 33%)"
        case .premiumLifetime:
            return "One-time purchase, lifetime access"
        }
    }
}
