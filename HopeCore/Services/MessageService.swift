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
    
    /// Current rotation state (loaded from SwiftData)
    private var rotationState: RotationState?

    private init() {}

    // MARK: - Message Loading

    /// Load all messages from SwiftData
    /// On first launch, loads bundled quotes from JSON and saves to SwiftData
    /// On subsequent launches, loads existing messages with user data preserved
    /// AGENT NOTE: Call this on app launch
    /// - Parameter modelContext: SwiftData model context
    func loadMessages(from modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            // Check if SwiftData has any messages
            let existingMessages = try modelContext.fetch(descriptor)

            if existingMessages.isEmpty {
                // First launch scenario - load bundled quotes
                print("📦 First launch detected - loading bundled quotes")

                let bundledQuotes = QuoteLoader.loadBundledQuotes()

                if !bundledQuotes.isEmpty {
                    // Insert bundled quotes into SwiftData
                    for quote in bundledQuotes {
                        modelContext.insert(quote)
                    }

                    // Save to SwiftData
                    try modelContext.save()
                    print("💾 Saved \(bundledQuotes.count) quotes to SwiftData")

                    // Set allMessages to bundled quotes
                    allMessages = bundledQuotes
                } else {
                    // Fallback to sample messages if bundle loading fails
                    print("⚠️ Bundled quotes failed to load - using sample messages")
                    allMessages = Message.sampleMessages

                    // Insert sample messages into SwiftData for future launches
                    for message in allMessages {
                        modelContext.insert(message)
                    }
                    try modelContext.save()
                }
            } else {
                // Subsequent launches - use existing messages with user data
                print("✅ Loaded \(existingMessages.count) messages from SwiftData")
                allMessages = existingMessages
            }

            updateFilteredMessages()
            loadSavedMessages()
            loadRotationState(from: modelContext)
        } catch {
            print("❌ Failed to load messages: \(error)")

            // Fallback to sample messages on error
            allMessages = Message.sampleMessages
        }
    }
    
    /// Load rotation state from SwiftData
    /// Creates new rotation state if none exists
    /// - Parameter modelContext: SwiftData model context
    private func loadRotationState(from modelContext: ModelContext) {
        let descriptor = FetchDescriptor<RotationState>()
        
        do {
            let existingStates = try modelContext.fetch(descriptor)
            
            if let existingState = existingStates.first {
                rotationState = existingState
                print("✅ Loaded rotation state (cycle \(existingState.currentCycle), \(existingState.seenMessageCount) messages, \(existingState.seenImageCount) images seen)")
            } else {
                // Create new rotation state
                let newState = RotationState()
                modelContext.insert(newState)
                try modelContext.save()
                rotationState = newState
                print("📦 Created new rotation state")
            }
        } catch {
            print("❌ Failed to load rotation state: \(error)")
            // Create fallback rotation state
            rotationState = RotationState()
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
                var regularMessages = selectRotatedMessages(count: regularCount)

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

    /// Select messages using round-robin rotation algorithm
    /// Ensures all messages (quotes) are seen before any repeats
    /// Images are part of the message presentation, not tracked separately
    /// Optimized for thousands of messages using Set-based lookups
    /// - Parameter count: Number of messages to select
    /// - Returns: Array of messages
    private func selectRotatedMessages(count: Int) -> [Message] {
        guard let rotationState = rotationState else {
            // Fallback to old algorithm if rotation state not available
            return selectRotatedMessagesLegacy(count: count)
        }
        
        let totalUniqueMessages = filteredMessages.count
        
        // Convert seenMessageIDs array to Set for O(1) lookups (critical for thousands of messages)
        let seenMessageIDsSet = Set(rotationState.seenMessageIDs)
        
        // Check if all messages have been seen
        let allMessagesSeen = totalUniqueMessages > 0 && seenMessageIDsSet.count >= totalUniqueMessages
        
        // If all messages have been seen, reset cycle
        if allMessagesSeen {
            print("🔄 All messages seen - resetting cycle")
            rotationState.resetCycle()
            // Update set after reset
            let updatedSeenSet = Set(rotationState.seenMessageIDs)
            return selectWithSeenSet(seenSet: updatedSeenSet, count: count)
        }
        
        return selectWithSeenSet(seenSet: seenMessageIDsSet, count: count)
    }
    
    /// Helper method to select messages using a Set for efficient lookups
    /// - Parameters:
    ///   - seenSet: Set of seen message ID strings
    ///   - count: Number of messages to select
    /// - Returns: Array of selected messages
    private func selectWithSeenSet(seenSet: Set<String>, count: Int) -> [Message] {
        // Select messages based on rotation priority
        var selectedMessages: [Message] = []
        var selectedIDs = Set<UUID>() // Use Set for O(1) contains checks
        var remainingCount = count
        
        // Priority 1: Unseen messages (quotes not yet shown in this cycle)
        // Use lazy filter and only process what we need
        let unseenMessages = filteredMessages.filter { message in
            !seenSet.contains(message.id.uuidString)
        }
        
        if !unseenMessages.isEmpty && remainingCount > 0 {
            let toSelect = min(remainingCount, unseenMessages.count)
            let selected = Array(unseenMessages.shuffled().prefix(toSelect))
            selectedMessages.append(contentsOf: selected)
            selectedIDs = Set(selected.map { $0.id })
            remainingCount -= toSelect
        }
        
        // Priority 2: Weighted random from all messages (fallback when all have been seen)
        // This happens after cycle reset, or if we need more messages than unseen ones
        if remainingCount > 0 {
            // Filter out already selected messages using Set for O(1) lookup
            let availableMessages = filteredMessages.filter { message in
                !selectedIDs.contains(message.id)
            }
            
            if !availableMessages.isEmpty {
                let weightedMessages = selectWeightedRandom(from: availableMessages, count: remainingCount)
                selectedMessages.append(contentsOf: weightedMessages)
            }
        }
        
        return selectedMessages
    }
    
    /// Legacy rotation algorithm (fallback)
    /// - Parameter count: Number of messages to select
    /// - Returns: Array of messages
    private func selectRotatedMessagesLegacy(count: Int) -> [Message] {
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
    
    /// Select messages using weighted random algorithm
    /// Weights based on time since last shown, shown count, and whether item is new
    /// - Parameters:
    ///   - messages: Messages to select from
    ///   - count: Number of messages to select
    /// - Returns: Array of selected messages
    private func selectWeightedRandom(from messages: [Message], count: Int) -> [Message] {
        guard !messages.isEmpty else { return [] }
        
        // Calculate weights for each message
        let weightedMessages = messages.map { message -> (Message, Double) in
            let weight = calculateWeight(for: message)
            return (message, weight)
        }
        
        // Select messages based on weights
        var selected: [Message] = []
        var remaining = weightedMessages
        
        for _ in 0..<min(count, messages.count) {
            guard !remaining.isEmpty else { break }
            
            // Calculate total weight
            let totalWeight = remaining.reduce(0.0) { $0 + $1.1 }
            
            // Select random point in weight range
            let randomPoint = Double.random(in: 0..<totalWeight)
            
            // Find message at that point
            var cumulativeWeight = 0.0
            var selectedIndex = 0
            for (index, (_, weight)) in remaining.enumerated() {
                cumulativeWeight += weight
                if cumulativeWeight >= randomPoint {
                    selectedIndex = index
                    break
                }
            }
            
            // Add selected message
            selected.append(remaining[selectedIndex].0)
            remaining.remove(at: selectedIndex)
        }
        
        return selected
    }
    
    /// Calculate weight for a message in weighted random selection
    /// - Parameter message: Message to calculate weight for
    /// - Returns: Weight value (higher = more likely to be selected)
    private func calculateWeight(for message: Message) -> Double {
        let baseWeight = 1.0
        
        // Time multiplier: longer since last shown = higher weight
        let daysSinceLastShown: Double
        if let lastShown = message.lastShownAt {
            let timeInterval = Date().timeIntervalSince(lastShown)
            daysSinceLastShown = timeInterval / (24 * 60 * 60)
        } else {
            // Never shown - give high bonus
            daysSinceLastShown = 100.0
        }
        let timeMultiplier = log(daysSinceLastShown + 1) * 2
        
        // Count multiplier: fewer times shown = higher weight
        let countMultiplier = 1.0 / Double(message.shownCount + 1)
        
        // New item bonus: never shown gets highest priority
        let newItemBonus = message.shownCount == 0 ? 10.0 : 1.0
        
        return baseWeight * timeMultiplier * countMultiplier * newItemBonus
    }

    // MARK: - Message Actions

    /// Mark message as shown
    /// Updates timestamp, count, and rotation state
    /// Only tracks the message/quote itself, not images separately
    /// - Parameters:
    ///   - message: Message that was shown
    ///   - modelContext: Optional SwiftData context to save rotation state
    func markAsShown(_ message: Message, modelContext: ModelContext? = nil) {
        message.lastShownAt = Date()
        message.shownCount += 1
        
        // Update rotation state - only track the message/quote
        guard let rotationState = rotationState else { return }
        
        // Mark message as seen in current cycle
        rotationState.markMessageAsSeen(message.id)
        
        // Note: We don't track images separately - they're just part of the message presentation
        
        // Save rotation state if context provided
        if let context = modelContext {
            try? context.save()
        }
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
    
    // MARK: - Rotation Helpers
    
    /// Get messages for rotation-aware feed
    /// Uses round-robin selection to ensure variety
    /// - Parameter count: Number of messages to return
    /// - Returns: Array of messages selected for rotation
    func getMessagesForFeed(count: Int = 50) -> [Message] {
        return selectRotatedMessages(count: count)
    }
    
    /// Get rotation state (for debugging/testing)
    /// - Returns: Current rotation state or nil
    func getRotationState() -> RotationState? {
        return rotationState
    }
}
