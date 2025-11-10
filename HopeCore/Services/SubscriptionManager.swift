//
//  SubscriptionManager.swift
//  HopeCore
//
//  Service - Subscription and In-App Purchase Management
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages StoreKit integration for premium subscriptions
//  - Handles free vs premium tier logic
//  - Validates subscription status and expiry
//  - Implements purchase flow and restoration
//  - Updates UserPreferences based on subscription state
//  - Future: Will integrate with App Store Connect products
//

import Foundation
import StoreKit
import SwiftData

/// Manages subscription state and purchases
/// Singleton service for centralized subscription logic
@Observable
class SubscriptionManager {
    static let shared = SubscriptionManager()

    /// Current subscription status
    var subscriptionStatus: SubscriptionStatus = .free

    /// Available products for purchase
    var availableProducts: [Product] = []

    /// Whether products are currently loading
    var isLoadingProducts = false

    /// Whether a purchase is in progress
    var isPurchasing = false

    /// Error message if purchase fails
    var purchaseError: String?

    /// Active subscription tier
    var currentTier: SubscriptionTier {
        switch subscriptionStatus {
        case .free:
            return .free
        case .premium:
            return .premium
        }
    }

    // Product IDs from App Store Connect
    private let productIDs = [
        IAPProductID.premiumMonthly.rawValue,
        IAPProductID.premiumYearly.rawValue,
        IAPProductID.premiumLifetime.rawValue
    ]

    private init() {
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Product Loading

    /// Load available products from App Store
    /// AGENT NOTE: Configure products in App Store Connect first
    func loadProducts() async {
        isLoadingProducts = true

        do {
            let products = try await Product.products(for: productIDs)
            await MainActor.run {
                self.availableProducts = products.sorted { $0.price < $1.price }
                self.isLoadingProducts = false
            }
        } catch {
            await MainActor.run {
                print("Failed to load products: \(error)")
                self.isLoadingProducts = false
            }
        }
    }

    // MARK: - Subscription Status

    /// Check current subscription status
    /// Validates active subscriptions and updates state
    func checkSubscriptionStatus() async {
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if subscription is still valid
                if let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {
                    await MainActor.run {
                        self.subscriptionStatus = .premium(expiryDate: expirationDate)
                    }
                    return
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        // No active subscription found
        await MainActor.run {
            self.subscriptionStatus = .free
        }
    }

    /// Verify transaction signature
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Purchase Flow

    /// Purchase a subscription product
    /// - Parameter product: Product to purchase
    func purchase(_ product: Product) async throws {
        await MainActor.run {
            isPurchasing = true
            purchaseError = nil
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)

                // Update subscription status
                await checkSubscriptionStatus()

                // Finish transaction
                await transaction.finish()

                await MainActor.run {
                    isPurchasing = false
                }

            case .userCancelled:
                await MainActor.run {
                    isPurchasing = false
                }

            case .pending:
                await MainActor.run {
                    isPurchasing = false
                    purchaseError = "Purchase is pending approval"
                }

            @unknown default:
                await MainActor.run {
                    isPurchasing = false
                    purchaseError = "Unknown purchase result"
                }
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                purchaseError = error.localizedDescription
            }
            throw error
        }
    }

    /// Restore previous purchases
    func restorePurchases() async throws {
        await MainActor.run {
            isPurchasing = true
            purchaseError = nil
        }

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()

            await MainActor.run {
                isPurchasing = false
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                purchaseError = "Failed to restore purchases"
            }
            throw error
        }
    }

    // MARK: - Subscription Features

    /// Check if a feature is available for current tier
    /// - Parameter feature: Feature to check
    /// - Returns: Whether feature is available
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        switch subscriptionStatus {
        case .free:
            return feature.availableInFree
        case .premium:
            return true
        }
    }

    /// Get maximum messages per day for current tier
    var maxMessagesPerDay: Int {
        return currentTier.maxMessagesPerDay
    }

    /// Whether demotivation messages are mandatory
    var demotivationMandatory: Bool {
        switch subscriptionStatus {
        case .free:
            return true
        case .premium:
            return false
        }
    }

    // MARK: - UserPreferences Integration

    /// Update user preferences based on subscription
    /// AGENT NOTE: Call this after purchase or status change
    /// - Parameter preferences: User preferences to update
    func updatePreferences(_ preferences: UserPreferences) {
        switch subscriptionStatus {
        case .free:
            preferences.subscriptionTier = "free"
            preferences.subscriptionExpiryDate = nil
            preferences.demotivationEnabled = true

            // Enforce free limits
            if preferences.messagesPerDay > 5 {
                preferences.messagesPerDay = 5
            }

        case .premium(let expiryDate):
            preferences.subscriptionTier = "premium"
            preferences.subscriptionExpiryDate = expiryDate
            preferences.demotivationEnabled = false // Disabled by default

            // Allow premium limits
            if preferences.messagesPerDay > 20 {
                preferences.messagesPerDay = 20
            }
        }
    }
}

// MARK: - Subscription Status Enum
enum SubscriptionStatus: Equatable {
    case free
    case premium(expiryDate: Date)

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .premium:
            return "Premium"
        }
    }

    var isPremium: Bool {
        if case .premium = self {
            return true
        }
        return false
    }
}

// MARK: - Premium Features
enum PremiumFeature {
    case unlimitedMessages // Up to 20/day
    case categoryFiltering
    case noDemotivation
    case priorityWidgets
    case offlineAudio
    case premiumAudioContent
    case earlyAccess

    var availableInFree: Bool {
        return false // All features are premium-only
    }

    var displayName: String {
        switch self {
        case .unlimitedMessages:
            return "Unlimited Messages"
        case .categoryFiltering:
            return "Category Filtering"
        case .noDemotivation:
            return "No Demotivation Messages"
        case .priorityWidgets:
            return "Priority Widget Updates"
        case .offlineAudio:
            return "Offline Audio"
        case .premiumAudioContent:
            return "Premium Audio Content"
        case .earlyAccess:
            return "Early Access"
        }
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: Error {
    case failedVerification
    case networkError
    case productNotFound
    case purchaseFailed

    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase"
        case .networkError:
            return "Network error occurred"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
