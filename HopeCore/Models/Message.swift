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
//  - Messages belong to categories for filtering
//  - Users can save/favorite messages locally
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

    /// Bundled image name from Assets (image card mode)
    var bundledImageCardName: String?

    // MARK: - Text Overlay Mode Assets
    /// Background image URL from R2 (text overlay mode)
    var backgroundImageURL: String?

    /// Bundled background name from Assets (text overlay mode)
    var bundledBackgroundName: String?

    // MARK: - Text Styling (for overlay mode)
    var textAlignment: String = "center"
    var textColorOverride: String?

    // MARK: - Standard Fields
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

    init(
        id: UUID = UUID(),
        text: String,
        presentationMode: MessagePresentationMode,
        imageCardURL: String? = nil,
        bundledImageCardName: String? = nil,
        backgroundImageURL: String? = nil,
        bundledBackgroundName: String? = nil,
        categoryName: String,
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
        self.bundledImageCardName = bundledImageCardName
        self.backgroundImageURL = backgroundImageURL
        self.bundledBackgroundName = bundledBackgroundName
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
        // Image card mode (full-screen image with baked-in text)
        Message(
            text: "A ship in the harbor is safe, but that is not what ships are built for.",
            presentationMode: .imageCard,
            bundledImageCardName: "test-image-1",
            categoryName: "Possibility"
        ),

        // Text overlay mode (background with text overlay)
        Message(
            text: "You'll never feel ready. Do it anyway.",
            presentationMode: .textOverlayBackground,
            bundledBackgroundName: "test-image-2",
            categoryName: "Agency"
        ),

        // Another image card
        Message(
            text: "Is this the life you really want?",
            presentationMode: .imageCard,
            bundledImageCardName: "test-image-3",
            categoryName: "Rebuilding"
        ),

        // Text overlay mode
        Message(
            text: "You are not who you were yesterday. Possibility lives in that space.",
            presentationMode: .textOverlayBackground,
            bundledBackgroundName: "test-image-1",
            categoryName: "Possibility"
        ),

        // Demotivation message - image card mode
        Message(
            text: "You'll probably fail at this too. Why even try?",
            presentationMode: .imageCard,
            bundledImageCardName: "test-image-2",
            categoryName: "Demotivation",
            isDemotivation: true
        )
    ]
}
