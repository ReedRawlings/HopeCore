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
//  - Matches JSON structure exactly
//

import Foundation

/// Decodable struct to parse JSON quotes
/// Used for loading bundled quotes on first launch with optional images
struct QuoteData: Codable, Identifiable {
    /// Unique identifier as UUID string
    let id: String

    /// Quote text content
    let text: String

    /// Category this quote belongs to
    let category: String

    /// Track type: "hope" or "demotivation"
    let trackType: String

    /// Sort order for organizing quotes
    let sortOrder: Int

    /// Optional bundled image name from Assets.xcassets
    let bundledImageName: String?

    /// Optional image URL from R2 Cloudflare storage
    let imageURL: String?

    // MARK: - Conversion to Message

    /// Convert QuoteData to Message model for SwiftData storage
    /// - Returns: Message instance with quote data, including optional image references
    func toMessage() -> Message {
        // Parse UUID from string ID
        let uuid = UUID(uuidString: id) ?? UUID()

        // Determine if this is a demotivation message
        let isDemotivation = trackType.lowercased() == "demotivation"

        // Create Message instance with optional bundled and R2 images
        let message = Message(
            id: uuid,
            text: text,
            imageURL: imageURL,  // Optional R2 image URL
            bundledImageName: bundledImageName,  // Optional bundled image from Assets
            categoryName: category,
            isSaved: false,
            createdAt: Date(),
            lastShownAt: nil,
            shownCount: 0,
            isDemotivation: isDemotivation
        )

        return message
    }
}
