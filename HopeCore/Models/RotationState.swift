//
//  RotationState.swift
//  HopeCore
//
//  Data Model - Rotation State for Round-Robin Message/Image Rotation
//  Created for round-robin rotation system
//
//  AGENT NOTES:
//  - Tracks which messages (quotes) have been seen in current rotation cycle
//  - Ensures no message repeats until all messages have been seen
//  - Images are part of message presentation, not tracked separately
//  - Supports cycle reset when all messages have been viewed
//  - Handles new content being added over time
//

import Foundation
import SwiftData

/// Tracks rotation state for round-robin message rotation
/// Ensures users see all messages (quotes) before any repeats
@Model
final class RotationState {
    /// Unique identifier (should only be one instance)
    var id: UUID
    
    /// Current rotation cycle identifier
    /// Increments when a cycle completes (all items seen)
    var currentCycle: Int
    
    /// Set of message IDs seen in current cycle
    /// Stored as array of UUID strings (SwiftData doesn't support Set directly)
    var seenMessageIDs: [String]
    
    /// Set of image identifiers seen in current cycle
    /// NOTE: Currently not used - we only track messages, not images separately
    /// Images are part of message presentation (imageCard or textOverlay mode)
    /// Stored as array of strings (SwiftData doesn't support Set directly)
    var seenImageIDs: [String]
    
    /// Last cycle reset date
    /// When the current cycle started
    var lastCycleResetDate: Date
    
    /// Total number of cycles completed
    /// Tracks how many full rotations have been completed
    var totalCyclesCompleted: Int
    
    init(
        id: UUID = UUID(),
        currentCycle: Int = 1,
        seenMessageIDs: [String] = [],
        seenImageIDs: [String] = [],
        lastCycleResetDate: Date = Date(),
        totalCyclesCompleted: Int = 0
    ) {
        self.id = id
        self.currentCycle = currentCycle
        self.seenMessageIDs = seenMessageIDs
        self.seenImageIDs = seenImageIDs
        self.lastCycleResetDate = lastCycleResetDate
        self.totalCyclesCompleted = totalCyclesCompleted
    }
}

// MARK: - Convenience Methods
extension RotationState {
    /// Check if a message has been seen in current cycle
    /// NOTE: For performance with thousands of messages, convert to Set in calling code
    /// This method uses array.contains() which is O(n) - fine for small sets, but
    /// MessageService converts to Set for efficient lookups at scale
    /// - Parameter messageID: UUID of the message
    /// - Returns: True if message has been seen in current cycle
    func hasSeenMessage(_ messageID: UUID) -> Bool {
        return seenMessageIDs.contains(messageID.uuidString)
    }
    
    /// Get seen message IDs as a Set for efficient lookups
    /// Use this when checking many messages (e.g., filtering thousands)
    /// - Returns: Set of seen message ID strings
    func getSeenMessageIDsSet() -> Set<String> {
        return Set(seenMessageIDs)
    }
    
    /// Check if an image has been seen in current cycle
    /// - Parameter imageID: Image identifier (URL or asset name)
    /// - Returns: True if image has been seen in current cycle
    func hasSeenImage(_ imageID: String) -> Bool {
        return seenImageIDs.contains(imageID)
    }
    
    /// Mark a message as seen in current cycle
    /// - Parameter messageID: UUID of the message
    func markMessageAsSeen(_ messageID: UUID) {
        let idString = messageID.uuidString
        if !seenMessageIDs.contains(idString) {
            seenMessageIDs.append(idString)
        }
    }
    
    /// Mark an image as seen in current cycle
    /// - Parameter imageID: Image identifier (URL or asset name)
    func markImageAsSeen(_ imageID: String) {
        if !seenImageIDs.contains(imageID) {
            seenImageIDs.append(imageID)
        }
    }
    
    /// Reset rotation cycle
    /// Clears seen sets and increments cycle counter
    func resetCycle() {
        seenMessageIDs.removeAll()
        seenImageIDs.removeAll()
        currentCycle += 1
        totalCyclesCompleted += 1
        lastCycleResetDate = Date()
    }
    
    /// Get count of seen messages in current cycle
    var seenMessageCount: Int {
        return seenMessageIDs.count
    }
    
    /// Get count of seen images in current cycle
    var seenImageCount: Int {
        return seenImageIDs.count
    }
}

