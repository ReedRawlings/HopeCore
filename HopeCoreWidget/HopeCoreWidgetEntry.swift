//
//  HopeCoreWidgetEntry.swift
//  HopeCoreWidget
//
//  Widget Extension - Timeline Entry Model
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - TimelineEntry is required by WidgetKit for widget updates
//  - Contains the data needed to render the widget at a specific point in time
//  - The 'date' property determines when this entry becomes active
//  - WidgetMessage is a lightweight struct for text-only display (no images)
//

import WidgetKit
import Foundation

// MARK: - Timeline Entry
/// Represents a single point in time for the widget display
/// Each entry contains the message to show and when it should be displayed
struct HopeCoreWidgetEntry: TimelineEntry {
    /// Date when this entry becomes active
    /// WidgetKit uses this to schedule when the widget updates
    let date: Date
    
    /// The message to display in the widget
    /// Optional because widget may show empty state when no message is available
    let message: WidgetMessage?
    
    // MARK: - Factory Methods
    
    /// Empty placeholder entry for initial loading state
    static let placeholder = HopeCoreWidgetEntry(
        date: Date(),
        message: nil
    )
    
    /// Sample entry for previews and gallery
    static let sample = HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "A ship in the harbor is safe, but that is not what ships are built for.",
            categoryName: "Possibility"
        )
    )
}

// MARK: - Widget Message
/// Lightweight message model for widget display
/// Contains only text data (no images) to keep widget fast and simple
/// AGENT NOTE: This is separate from the main Message model to avoid importing SwiftData
struct WidgetMessage {
    /// Unique identifier matching the Message in main app
    /// Used for deep linking when widget is tapped
    let id: UUID
    
    /// The quote/message text to display
    let text: String
    
    /// Category name for optional badge display
    let categoryName: String
    
    /// Deep link URL to open this specific message in the app
    var deepLinkURL: URL? {
        URL(string: "hopecore://message/\(id.uuidString)")
    }
}

