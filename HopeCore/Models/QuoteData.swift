//
//  QuoteData.swift
//  HopeCore
//
//  Model - Decodable struct for parsing JSON quotes
//  Created for bundled quotes system
//
//  AGENT NOTES:
//  - Used to parse quotes from bundled quotes.json file
//  - Converts to Message objects for SwiftData storage
//  - Supports both old format (single category) and new format (multiple categories)
//  - Supports optional author field
//

import Foundation

/// Decodable struct to parse JSON quotes
/// Used for loading bundled quotes on first launch with optional images
struct QuoteData: Codable, Identifiable {
    /// Unique identifier as UUID string
    let id: String

    /// Quote text content
    let text: String

    /// Categories this quote belongs to (new multi-category format)
    let categories: [String]?

    /// Category this quote belongs to (legacy single category format)
    let category: String?

    /// Author/attribution for the quote (optional)
    let author: String?

    /// Track type: "hope" or "demotivation"
    let trackType: String

    // MARK: - Presentation Mode
    /// Explicitly specify "imageCard" or "textOverlay"
    let presentationMode: String

    // MARK: - Image Card Assets
    /// Optional image URL from R2 Cloudflare storage (image card mode)
    let imageCardURL: String?

    // MARK: - Text Styling
    /// Text alignment for overlay mode
    let textAlignment: String?

    /// Text color override for overlay mode
    let textColorOverride: String?

    // MARK: - Computed Properties

    /// Resolved categories (handles both old and new format)
    var resolvedCategories: [String] {
        // Prefer new format (categories array)
        if let categories = categories, !categories.isEmpty {
            return categories
        }
        // Fall back to old format (single category)
        if let category = category, !category.isEmpty {
            return [category]
        }
        // Default
        return ["Possibility"]
    }

    // MARK: - Conversion to Message

    /// Convert QuoteData to Message model for SwiftData storage
    /// - Returns: Message instance with quote data, including optional image references
    func toMessage() -> Message {
        // Parse UUID from string ID
        let uuid = UUID(uuidString: id) ?? UUID()

        // Determine if this is a demotivation message
        let isDemotivation = trackType.lowercased() == "demotivation"

        // Convert presentation mode string to enum
        let mode = MessagePresentationMode(rawValue: presentationMode) ?? .textOverlayBackground

        // Create Message instance with presentation mode and appropriate assets
        // Note: backgroundImageURL is not set from JSON - textOverlay messages use user's default background from preferences
        let message = Message(
            id: uuid,
            text: text,
            presentationMode: mode,
            imageCardURL: imageCardURL,  // Optional R2 image URL (image card mode)
            backgroundImageURL: nil,  // Text overlay mode uses user's default background from preferences
            categories: resolvedCategories,
            author: author,
            isSaved: false,
            createdAt: Date(),
            lastShownAt: nil,
            shownCount: 0,
            isDemotivation: isDemotivation
        )

        return message
    }
}
