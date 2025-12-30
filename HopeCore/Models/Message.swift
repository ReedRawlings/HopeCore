//
//  Message.swift
//  HopeCore
//
//  Data Model - Hopecore Message
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Messages are the core content of the app
//  - Dual presentation modes: imageCard (full-screen with baked-in text) or textOverlayBackground
//  - Messages can belong to multiple categories for flexible filtering
//  - Users can save/favorite messages locally
//
//  CATEGORIES (8 total):
//  - Agency: Taking action, control, making choices
//  - Possibility: Hope, dreams, future potential
//  - Resilience: Bouncing back, overcoming adversity
//  - Growth: Learning, transformation, becoming
//  - Self-Worth: Identity, confidence, self-belief
//  - Connection: Community, relationships, kindness
//  - Mindfulness: Presence, peace, acceptance
//  - Purpose: Meaning, direction, passion
//

import Foundation
import SwiftData

/// Hopecore message with dual presentation modes
/// Core content model for the entire app
@Model
final class Message {
    /// Unique identifier
    var id: UUID

    /// Message text content
    var text: String

    /// Determines how this message is presented
    var presentationMode: MessagePresentationMode

    // MARK: - Image Card Mode Assets
    /// Full-screen image URL from R2 (image card mode)
    var imageCardURL: String?

    // MARK: - Text Overlay Mode Assets
    /// Background image URL from R2 (text overlay mode)
    var backgroundImageURL: String?

    // MARK: - Text Styling (for overlay mode)
    var textAlignment: String = "center"
    var textColorOverride: String?

    // MARK: - Standard Fields
    /// Categories this message belongs to (multi-category support)
    /// First category is considered the "primary" category
    var categories: [String]

    /// Author/attribution for the quote (optional)
    var author: String?

    /// Whether the user has saved/favorited this message
    var isSaved: Bool

    /// Timestamp when message was created/added
    var createdAt: Date

    /// Timestamp when message was last shown to user
    var lastShownAt: Date?

    /// Number of times this message has been shown
    var shownCount: Int

    /// Whether this is a demotivation message
    var isDemotivation: Bool

    // MARK: - Computed Properties

    /// Primary category (first in the list) - for backwards compatibility
    var categoryName: String {
        categories.first ?? "Possibility"
    }

    /// Check if message belongs to a specific category
    func hasCategory(_ category: String) -> Bool {
        categories.contains(category)
    }

    init(
        id: UUID = UUID(),
        text: String,
        presentationMode: MessagePresentationMode,
        imageCardURL: String? = nil,
        backgroundImageURL: String? = nil,
        categories: [String] = ["Possibility"],
        author: String? = nil,
        isSaved: Bool = false,
        createdAt: Date = Date(),
        lastShownAt: Date? = nil,
        shownCount: Int = 0,
        isDemotivation: Bool = false
    ) {
        self.id = id
        self.text = text
        self.presentationMode = presentationMode
        self.imageCardURL = imageCardURL
        self.backgroundImageURL = backgroundImageURL
        self.categories = categories
        self.author = author
        self.isSaved = isSaved
        self.createdAt = createdAt
        self.lastShownAt = lastShownAt
        self.shownCount = shownCount
        self.isDemotivation = isDemotivation
    }

    /// Convenience init for single category (backwards compatibility)
    convenience init(
        id: UUID = UUID(),
        text: String,
        presentationMode: MessagePresentationMode,
        imageCardURL: String? = nil,
        backgroundImageURL: String? = nil,
        categoryName: String,
        author: String? = nil,
        isSaved: Bool = false,
        createdAt: Date = Date(),
        lastShownAt: Date? = nil,
        shownCount: Int = 0,
        isDemotivation: Bool = false
    ) {
        self.init(
            id: id,
            text: text,
            presentationMode: presentationMode,
            imageCardURL: imageCardURL,
            backgroundImageURL: backgroundImageURL,
            categories: [categoryName],
            author: author,
            isSaved: isSaved,
            createdAt: createdAt,
            lastShownAt: lastShownAt,
            shownCount: shownCount,
            isDemotivation: isDemotivation
        )
    }
}

// MARK: - Sample Messages
extension Message {
    /// Sample messages for development and preview
    /// AGENT NOTE: Replace with actual content from backend/CMS
    /// Uses R2 URLs for all images - update with actual filenames from your R2 bucket
    static let sampleMessages: [Message] = [
        // Image card mode (full-screen image with baked-in text)
        Message(
            text: "A ship in the harbor is safe, but that is not what ships are built for.",
            presentationMode: .imageCard,
            imageCardURL: "https://pub-0017d537075f47dba685fa2a8ebf5591.r2.dev/A%20ship%20in%20the%20harbor%20is%20safe%2C%20but%20that%20is%20not%20what%20ships%20are%20built%20for..png",
            categoryName: "Possibility"
        ),

        // Text overlay mode (background with text overlay)
        Message(
            text: "You'll never feel ready. Do it anyway.",
            presentationMode: .textOverlayBackground,
            backgroundImageURL: "https://pub-0017d537075f47dba685fa2a8ebf5591.r2.dev/doitanyway.png",
            categoryName: "Agency"
        ),

        // Another image card
        Message(
            text: "Is this the life you really want?",
            presentationMode: .imageCard,
            imageCardURL: "https://pub-0017d537075f47dba685fa2a8ebf5591.r2.dev/thelifeyouwant.png",
            categoryName: "Rebuilding"
        )
    ]
}
