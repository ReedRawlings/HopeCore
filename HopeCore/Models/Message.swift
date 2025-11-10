//
//  Message.swift
//  HopeCore
//
//  Data Model - Hopecore Message
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Messages are the core content of the app
//  - Each message has text + paired imagery (URL from R2 Cloudflare)
//  - Presentation modes: image+text, text-on-background, split, minimal
//  - Messages belong to categories for filtering
//  - Users can save/favorite messages locally
//  - Images are cached locally after download from R2
//

import Foundation
import SwiftData

/// Hopecore message with image-text pairing
/// Core content model for the entire app
@Model
final class Message {
    /// Unique identifier
    var id: UUID

    /// Message text content
    var text: String

    /// Image URL (R2 Cloudflare storage)
    /// AGENT NOTE: This is fetched and cached locally
    var imageURL: String?

    /// Local cached image filename (if downloaded)
    var cachedImageFilename: String?

    /// Category this message belongs to
    var categoryName: String

    /// Presentation mode for the message card
    /// Options: "imageText", "textOnBackground", "split", "minimal"
    var presentationMode: String

    /// Optional author/source attribution
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

    /// Sort order for featured messages
    var sortOrder: Int?

    init(
        id: UUID = UUID(),
        text: String,
        imageURL: String? = nil,
        cachedImageFilename: String? = nil,
        categoryName: String,
        presentationMode: String = "imageText",
        author: String? = nil,
        isSaved: Bool = false,
        createdAt: Date = Date(),
        lastShownAt: Date? = nil,
        shownCount: Int = 0,
        isDemotivation: Bool = false,
        sortOrder: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.imageURL = imageURL
        self.cachedImageFilename = cachedImageFilename
        self.categoryName = categoryName
        self.presentationMode = presentationMode
        self.author = author
        self.isSaved = isSaved
        self.createdAt = createdAt
        self.lastShownAt = lastShownAt
        self.shownCount = shownCount
        self.isDemotivation = isDemotivation
        self.sortOrder = sortOrder
    }
}

// MARK: - Presentation Mode Enum
/// Defines how a message should be visually presented
/// AGENT NOTE: Aligns with designdoc.md presentation modes
enum MessagePresentationMode: String, CaseIterable {
    /// Illustration + centered text (most common)
    case imageText = "imageText"

    /// Image background + overlaid text
    case textOnBackground = "textOnBackground"

    /// Split layout: image left, text right
    case split = "split"

    /// Minimal text + subtle background
    case minimal = "minimal"

    var description: String {
        switch self {
        case .imageText:
            return "Image at top, text below with clear separation"
        case .textOnBackground:
            return "Text overlaid on background image (opacity 0.4)"
        case .split:
            return "Side-by-side: 50% image, 50% text"
        case .minimal:
            return "Subtle background texture with prominent typography"
        }
    }
}

// MARK: - Sample Messages
extension Message {
    /// Sample messages for development and preview
    /// AGENT NOTE: Replace with actual content from backend/CMS
    static let sampleMessages: [Message] = [
        Message(
            text: "You have survived 100% of your worst days. That's a perfect record.",
            imageURL: "https://r2.example.com/resilience-1.jpg",
            categoryName: "Resilience",
            presentationMode: "imageText",
            author: "Unknown"
        ),
        Message(
            text: "Small choices compound. You're building something, even if you can't see it yet.",
            imageURL: "https://r2.example.com/agency-1.jpg",
            categoryName: "Agency",
            presentationMode: "textOnBackground",
            author: "HopeCore Team"
        ),
        Message(
            text: "Rebuilding doesn't mean going back. It means creating something new from what you've learned.",
            imageURL: "https://r2.example.com/rebuilding-1.jpg",
            categoryName: "Rebuilding",
            presentationMode: "imageText"
        ),
        Message(
            text: "You are not who you were yesterday. Possibility lives in that space.",
            imageURL: "https://r2.example.com/possibility-1.jpg",
            categoryName: "Possibility",
            presentationMode: "minimal"
        ),
        Message(
            text: "You'll probably fail at this too. Why even try?",
            categoryName: "Demotivation",
            presentationMode: "textOnBackground",
            isDemotivation: true
        )
    ]
}
