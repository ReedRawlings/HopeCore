//
//  MessageService.swift
//  HopeCore
//
//  Service - Message Management and Delivery
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages message library (fetch, filter, selection)
//  - Implements message rotation algorithm
//  - Handles saved/favorited messages
//  - Tracks message view counts and timestamps
//  - Supports category filtering for premium users
//  - Future: Will sync with backend/CMS for content updates
//

import Foundation
import SwiftData

/// Manages hopecore message library and delivery
/// Centralized service for all message operations
@Observable
class MessageService {
    static let shared = MessageService()

    /// All available messages (loaded from storage)
    var allMessages: [Message] = []

    /// Messages filtered by user preferences
    var filteredMessages: [Message] = []

    /// Saved/favorited messages
    var savedMessages: [Message] = []

    /// Today's featured message
    var todaysFeaturedMessage: Message?

    private init() {}

    // MARK: - Message Loading

    /// Load all messages from SwiftData
    /// AGENT NOTE: Call this on app launch
    /// - Parameter modelContext: SwiftData model context
    func loadMessages(from modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            allMessages = try modelContext.fetch(descriptor)
            updateFilteredMessages()
            loadSavedMessages()
        } catch {
            print("Failed to load messages: \(error)")
        }
    }

    /// Load saved messages
    private func loadSavedMessages() {
        savedMessages = allMessages.filter { $0.isSaved }
    }

    // MARK: - Message Filtering

    /// Update filtered messages based on preferences
    /// - Parameter preferences: User preferences for filtering
    func updateFilteredMessages(with preferences: UserPreferences? = nil) {
        filteredMessages = allMessages.filter { message in
            // Exclude demotivation messages from regular feed
            guard !message.isDemotivation else { return false }

            // If no preferences or no category filter, show all
            guard let prefs = preferences,
                  !prefs.selectedCategoryIDs.isEmpty else {
                return true
            }

            // AGENT NOTE: Implement category ID matching
            // For now, just return true
            return true
        }
    }

    /// Get messages by category
    /// - Parameter category: Category name
    /// - Returns: Messages in that category
    func getMessages(for category: String) -> [Message] {
        return allMessages.filter { $0.categoryName == category && !$0.isDemotivation }
    }

    /// Get random message excluding recently shown
    /// AGENT NOTE: Implements basic rotation to avoid repetition
    /// - Parameter excludeRecent: Number of recent messages to exclude
    /// - Returns: Random message
    func getRandomMessage(excludeRecent: Int = 10) -> Message? {
        // Get messages sorted by last shown date (oldest first)
        let sorted = filteredMessages.sorted { msg1, msg2 in
            let date1 = msg1.lastShownAt ?? Date.distantPast
            let date2 = msg2.lastShownAt ?? Date.distantPast
            return date1 < date2
        }

        // Get messages not recently shown
        let availableMessages = Array(sorted.prefix(filteredMessages.count - excludeRecent))

        return availableMessages.randomElement()
    }

    // MARK: - Message Selection for Notifications

    /// Select messages for today's notifications
    /// Respects rotation and demotivation patterns
    /// - Parameters:
    ///   - count: Number of messages to select
    ///   - preferences: User preferences
    /// - Returns: Array of selected messages
    func selectMessagesForToday(
        count: Int,
        preferences: UserPreferences
    ) -> [Message] {
        var selectedMessages: [Message] = []

        // Determine if we should include demotivation message
        let includeDemotivation = preferences.shouldSendDemotivation

        if includeDemotivation {
            // Get demotivation messages
            let demotivationMessages = allMessages.filter { $0.isDemotivation }

            if let demotivationMessage = demotivationMessages.randomElement() {
                // Select regular messages
                let regularCount = count - 1
                let regularMessages = selectRotatedMessages(count: regularCount)

                // Insert demotivation at random position
                let randomPosition = Int.random(in: 0..<count)
                for i in 0..<count {
                    if i == randomPosition {
                        selectedMessages.append(demotivationMessage)
                    } else if !regularMessages.isEmpty {
                        selectedMessages.append(regularMessages.removeFirst())
                    }
                }
            }
        } else {
            // Just select regular messages
            selectedMessages = selectRotatedMessages(count: count)
        }

        return selectedMessages
    }

    /// Select messages using rotation algorithm
    /// Prioritizes messages shown least recently
    /// - Parameter count: Number of messages to select
    /// - Returns: Array of messages
    private func selectRotatedMessages(count: Int) -> [Message] {
        // Sort by last shown date (oldest first) and shown count (least shown first)
        let sorted = filteredMessages.sorted { msg1, msg2 in
            let date1 = msg1.lastShownAt ?? Date.distantPast
            let date2 = msg2.lastShownAt ?? Date.distantPast

            if date1 == date2 {
                return msg1.shownCount < msg2.shownCount
            }

            return date1 < date2
        }

        // Take top candidates (oldest/least shown)
        let candidates = Array(sorted.prefix(min(count * 3, sorted.count)))

        // Randomly select from candidates
        return candidates.shuffled().prefix(count).map { $0 }
    }

    // MARK: - Message Actions

    /// Mark message as shown
    /// Updates timestamp and count
    /// - Parameter message: Message that was shown
    func markAsShown(_ message: Message) {
        message.lastShownAt = Date()
        message.shownCount += 1
    }

    /// Toggle message saved state
    /// - Parameter message: Message to toggle
    func toggleSaved(_ message: Message) {
        message.isSaved.toggle()

        if message.isSaved {
            savedMessages.append(message)
        } else {
            savedMessages.removeAll { $0.id == message.id }
        }
    }

    /// Save message to favorites
    /// - Parameter message: Message to save
    func saveMessage(_ message: Message) {
        guard !message.isSaved else { return }

        message.isSaved = true
        savedMessages.append(message)
    }

    /// Remove message from favorites
    /// - Parameter message: Message to remove
    func unsaveMessage(_ message: Message) {
        guard message.isSaved else { return }

        message.isSaved = false
        savedMessages.removeAll { $0.id == message.id }
    }

    // MARK: - Featured Message

    /// Set today's featured message
    /// AGENT NOTE: Call this daily to update home screen
    /// - Parameter preferences: User preferences
    func selectTodaysFeaturedMessage(preferences: UserPreferences) {
        if let message = getRandomMessage(excludeRecent: 5) {
            todaysFeaturedMessage = message
            markAsShown(message)
        }
    }

    // MARK: - Content Management (Future)

    /// Fetch latest messages from backend
    /// AGENT NOTE: Implement when backend/CMS is ready
    /// - Returns: Newly downloaded messages
    func fetchLatestMessages() async throws -> [Message] {
        // Placeholder for future implementation
        // Will fetch from R2/backend API
        return []
    }

    /// Sync local messages with backend
    /// AGENT NOTE: Implement for content updates
    func syncMessages() async throws {
        // Placeholder for future implementation
    }
}
