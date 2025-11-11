//
//  QuoteLoader.swift
//  HopeCore
//
//  Service - Load quotes from bundled JSON
//  Created for bundled quotes system
//
//  AGENT NOTES:
//  - Loads text-only quotes from quotes.json in app bundle
//  - Called on first launch when SwiftData is empty
//  - Converts JSON to Message objects
//  - Includes comprehensive error handling
//

import Foundation

/// Service to load quotes from bundled JSON file
struct QuoteLoader {

    /// Load quotes from bundled quotes.json file
    /// - Returns: Array of Message objects parsed from JSON
    static func loadBundledQuotes() -> [Message] {
        // Find quotes.json in main bundle
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
            print("❌ Could not find quotes.json in bundle")
            return []
        }

        do {
            // Load data from file
            let data = try Data(contentsOf: url)

            // Decode JSON into QuoteData array
            let decoder = JSONDecoder()
            let quoteDataArray = try decoder.decode([QuoteData].self, from: data)

            // Convert to Message objects
            let messages = quoteDataArray.map { $0.toMessage() }

            // Success logging
            print("✅ Loaded \(messages.count) quotes from bundle")

            return messages

        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Failed to load quotes: Data corrupted - \(context.debugDescription)")
            return []

        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Failed to load quotes: Key '\(key.stringValue)' not found - \(context.debugDescription)")
            return []

        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Failed to load quotes: Type mismatch for type \(type) - \(context.debugDescription)")
            return []

        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ Failed to load quotes: Value not found for type \(type) - \(context.debugDescription)")
            return []

        } catch {
            print("❌ Failed to load quotes: \(error.localizedDescription)")
            return []
        }
    }
}
