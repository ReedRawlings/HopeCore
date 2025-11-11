//
//  Message.swift
//  HopeCore
//
//  Data Model - Hopecore Message
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Messages are the core content of the app
//  - Simplified architecture: imageURL contains full-screen image with baked-in text, OR
//  - text is shown centered on dark background if imageURL is nil
//  - Messages belong to categories for filtering
//  - Users can save/favorite messages locally
//

import Foundation
import SwiftData

/// Hopecore message with simplified presentation
/// Core content model for the entire app
@Model
final class Message {
    /// Unique identifier
    var id: UUID

    /// Message text content (only used when NO image)
    var text: String

    /// Image URL (R2 Cloudflare storage)
    /// Full image with baked-in text - displays full screen
    var imageURL: String?

    /// Category this message belongs to
    var categoryName: String

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

    /// Bundled image name (from Assets.xcassets) - for development
    /// Example: "test-image-1"
    var bundledImageName: String?

    init(
        id: UUID = UUID(),
        text: String,
        imageURL: String? = nil,
        bundledImageName: String? = nil,
        categoryName: String,
        isSaved: Bool = false,
        createdAt: Date = Date(),
        lastShownAt: Date? = nil,
        shownCount: Int = 0,
        isDemotivation: Bool = false
    ) {
        self.id = id
        self.text = text
        self.imageURL = imageURL
        self.bundledImageName = bundledImageName
        self.categoryName = categoryName
        self.isSaved = isSaved
        self.createdAt = createdAt
        self.lastShownAt = lastShownAt
        self.shownCount = shownCount
        self.isDemotivation = isDemotivation
    }
}

// MARK: - Sample Messages
extension Message {
    /// Sample messages for development and preview
    /// AGENT NOTE: Replace with actual content from backend/CMS
    static let sampleMessages: [Message] = [
        Message(
            text: "A ship in the harbor is safe, but that is not what ships are built for.",
            imageURL: "test-image-1"
            categoryName: "Possibility"
        ),
        Message(
            text: "You'll never feel ready. Do it anyway.",
            imageURL: "test-image-2",
            categoryName: "Agency"
        ),
        Message(
            text: "Is this the life you really want?",
            imageURL: test-image-3",
            categoryName: "Rebuilding"
        ),
        Message(
            text: "You are not who you were yesterday. Possibility lives in that space.",
            categoryName: "Possibility"
        ),
        Message(
            text: "You'll probably fail at this too. Why even try?",
            categoryName: "Demotivation",
            isDemotivation: true
        )
    ]
}
