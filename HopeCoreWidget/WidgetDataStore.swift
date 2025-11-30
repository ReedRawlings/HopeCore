//
//  WidgetDataStore.swift
//  HopeCoreWidget
//
//  Shared Data Store for Widget Communication
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - This file is shared between the main app and widget extension
//  - Uses App Group UserDefaults for cross-process data sharing
//  - App Group ID must match in both targets: group.com.hopecore.shared
//  - Stores text-only data (no images) to keep widget fast
//  - Main app writes, widget reads
//
//  IMPORTANT: This file should be added to BOTH targets:
//  1. HopeCore (main app) - for writing message data
//  2. HopeCoreWidget (widget extension) - for reading message data
//

import Foundation

// MARK: - Widget Data Store
/// Manages shared data between main app and widget extension
/// Uses App Group UserDefaults for cross-process communication
struct WidgetDataStore {
    
    // MARK: - Configuration
    
    /// App Group identifier - MUST match in both targets' entitlements
    /// CRITICAL: Verify this is enabled in Signing & Capabilities for both targets
    private static let appGroupID = "group.com.hopecore.shared"
    
    /// UserDefaults keys for stored data
    private static let messageDataKey = "todaysFeaturedMessage"
    private static let messageIDKey = "todaysFeaturedMessageID"
    private static let lastUpdatedKey = "widgetLastUpdated"
    private static let isPremiumKey = "widgetIsPremium"
    private static let scheduledMessagesKey = "widgetScheduledMessages" // Array of [time: message] pairs
    
    // MARK: - Shared UserDefaults
    
    /// Access to App Group shared UserDefaults
    /// Returns nil if App Group is not properly configured
    static var sharedDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: appGroupID)
        if defaults == nil {
            print("❌ WidgetDataStore: Failed to access App Group UserDefaults")
            print("   Verify App Group '\(appGroupID)' is enabled in both targets")
        }
        return defaults
    }
    
    // MARK: - Write Methods (Called from Main App)
    
    /// Save today's featured message for widget display
    /// Called from MessageService.selectTodaysFeaturedMessage()
    /// - Parameters:
    ///   - id: Message UUID for deep linking
    ///   - text: Quote text to display
    ///   - categoryName: Category for badge display
    static func saveTodaysMessage(id: UUID, text: String, categoryName: String) {
        guard let defaults = sharedDefaults else {
            print("❌ WidgetDataStore: Cannot save - App Group not accessible")
            return
        }
        
        // Store message data as dictionary (serializable)
        let messageData: [String: Any] = [
            "id": id.uuidString,
            "text": text,
            "categoryName": categoryName,
            "savedAt": Date().timeIntervalSince1970
        ]
        
        defaults.set(messageData, forKey: messageDataKey)
        defaults.set(id.uuidString, forKey: messageIDKey)
        defaults.set(Date().timeIntervalSince1970, forKey: lastUpdatedKey)
        
        // Force synchronize to ensure data is available to widget immediately
        defaults.synchronize()
        
        print("✅ WidgetDataStore: Saved message for widget")
        print("   ID: \(id.uuidString)")
        print("   Text: \(text.prefix(50))...")
        print("   Category: \(categoryName)")
    }
    
    /// Update premium status for widget update frequency
    /// - Parameter isPremium: Whether user has premium subscription
    static func updatePremiumStatus(_ isPremium: Bool) {
        guard let defaults = sharedDefaults else { return }
        defaults.set(isPremium, forKey: isPremiumKey)
        defaults.synchronize()
    }
    
    // MARK: - Read Methods (Called from Widget)
    
    /// Get today's featured message for widget display
    /// - Returns: WidgetMessage if available, nil if no message saved
    static func getTodaysMessage() -> WidgetMessage? {
        guard let defaults = sharedDefaults,
              let messageData = defaults.dictionary(forKey: messageDataKey) else {
            print("⚠️ WidgetDataStore: No message data found")
            return nil
        }
        
        // Parse message data
        guard let idString = messageData["id"] as? String,
              let text = messageData["text"] as? String,
              let categoryName = messageData["categoryName"] as? String,
              let messageID = UUID(uuidString: idString) else {
            print("❌ WidgetDataStore: Failed to parse message data")
            return nil
        }
        
        return WidgetMessage(
            id: messageID,
            text: text,
            categoryName: categoryName
        )
    }
    
    /// Get the ID of today's featured message
    /// Used for navigation when widget is tapped
    /// - Returns: UUID of the featured message, or nil
    static func getTodaysMessageID() -> UUID? {
        guard let defaults = sharedDefaults,
              let idString = defaults.string(forKey: messageIDKey),
              let uuid = UUID(uuidString: idString) else {
            return nil
        }
        return uuid
    }
    
    /// Check if user has premium subscription
    /// - Returns: true if premium, false otherwise
    static func isPremium() -> Bool {
        return sharedDefaults?.bool(forKey: isPremiumKey) ?? false
    }
    
    /// Get last update timestamp
    /// - Returns: Date of last widget data update, or nil
    static func getLastUpdated() -> Date? {
        guard let defaults = sharedDefaults,
              let timestamp = defaults.object(forKey: lastUpdatedKey) as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    // MARK: - Utility Methods
    
    /// Check if widget data needs refresh
    /// Returns true if data is older than 24 hours
    static func needsRefresh() -> Bool {
        guard let lastUpdated = getLastUpdated() else {
            return true // No data, needs refresh
        }
        
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdated) / 3600
        return hoursSinceUpdate >= 24
    }
    
    /// Get all scheduled messages for today
    /// - Returns: Array of (time, message) tuples sorted by time
    static func getScheduledMessages() -> [(time: Date, message: WidgetMessage)] {
        guard let defaults = sharedDefaults,
              let scheduleData = defaults.array(forKey: scheduledMessagesKey) as? [[String: Any]] else {
            return []
        }
        
        var schedule: [(Date, WidgetMessage)] = []
        
        for item in scheduleData {
            guard let timeInterval = item["time"] as? TimeInterval,
                  let messageDict = item["message"] as? [String: Any],
                  let idString = messageDict["id"] as? String,
                  let text = messageDict["text"] as? String,
                  let categoryName = messageDict["categoryName"] as? String,
                  let messageID = UUID(uuidString: idString) else {
                continue
            }
            
            let time = Date(timeIntervalSince1970: timeInterval)
            let message = WidgetMessage(id: messageID, text: text, categoryName: categoryName)
            schedule.append((time, message))
        }
        
        // Sort by time
        schedule.sort { $0.0 < $1.0 }
        
        return schedule
    }
    
    /// Get the message scheduled for a specific time (or closest upcoming time)
    /// - Parameter forTime: Time to check
    /// - Returns: WidgetMessage if found, nil otherwise
    static func getMessageForTime(_ forTime: Date) -> WidgetMessage? {
        let schedule = getScheduledMessages()
        
        // Find the message scheduled for this time or the next upcoming one
        // If it's past all scheduled times, return the last one
        for (time, message) in schedule {
            if time <= forTime {
                // This message should be shown (time has passed or is now)
                return message
            }
        }
        
        // If we haven't reached any scheduled time yet, return the first one
        return schedule.first?.1
    }
    
    /// Clear all widget data
    /// Used for testing or when user logs out
    static func clearAll() {
        guard let defaults = sharedDefaults else { return }
        defaults.removeObject(forKey: messageDataKey)
        defaults.removeObject(forKey: messageIDKey)
        defaults.removeObject(forKey: lastUpdatedKey)
        defaults.removeObject(forKey: isPremiumKey)
        defaults.removeObject(forKey: scheduledMessagesKey)
        defaults.synchronize()
        print("🧹 WidgetDataStore: Cleared all widget data")
    }
}

