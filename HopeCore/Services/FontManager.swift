//
//  FontManager.swift
//  HopeCore
//
//  Manages custom fonts for text overlay messages
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Uses iOS built-in fonts (no custom font files needed)
//  - All fonts are pre-installed on iOS and work in widgets
//  - Fonts chosen for readability and emotional impact
//  - Each font has display name, font name, and category
//  - Widget-safe: all fonts work in both app and widget extension
//

import SwiftUI

// MARK: - Font Category

/// Categories for organizing available fonts
enum FontCategory: String, CaseIterable {
    case serif = "Serif"
    case sansSerif = "Sans Serif"
    case display = "Display"
    case handwritten = "Handwritten"
}

// MARK: - Custom Font Definition

/// Represents a custom font option for message display
struct CustomFont: Identifiable, Equatable {
    let id: String
    let displayName: String
    let fontName: String
    let category: FontCategory
    let previewText: String

    /// Creates a SwiftUI Font at the specified size
    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Map weight to UIFont.Weight for custom fonts
        let uiWeight: UIFont.Weight
        switch weight {
        case .ultraLight: uiWeight = .ultraLight
        case .thin: uiWeight = .thin
        case .light: uiWeight = .light
        case .regular: uiWeight = .regular
        case .medium: uiWeight = .medium
        case .semibold: uiWeight = .semibold
        case .bold: uiWeight = .bold
        case .heavy: uiWeight = .heavy
        case .black: uiWeight = .black
        default: uiWeight = .regular
        }

        // Try to create the custom font, fallback to system if not available
        if let uiFont = UIFont(name: fontName, size: size) {
            return Font(uiFont)
        }

        // Fallback to system font
        return .system(size: size, weight: weight)
    }
}

// MARK: - Font Manager

/// Manages available fonts for message display
/// All fonts are iOS built-in fonts that work in both app and widgets
@Observable
final class FontManager {

    // MARK: - Singleton

    static let shared = FontManager()

    // MARK: - Properties

    /// All available custom fonts
    let availableFonts: [CustomFont] = [
        // MARK: Serif Fonts - Classic, literary feel
        CustomFont(
            id: "georgia",
            displayName: "Georgia",
            fontName: "Georgia",
            category: .serif,
            previewText: "Classic elegance"
        ),
        CustomFont(
            id: "georgia-bold",
            displayName: "Georgia Bold",
            fontName: "Georgia-Bold",
            category: .serif,
            previewText: "Bold statement"
        ),
        CustomFont(
            id: "palatino",
            displayName: "Palatino",
            fontName: "Palatino-Roman",
            category: .serif,
            previewText: "Timeless wisdom"
        ),
        CustomFont(
            id: "baskerville",
            displayName: "Baskerville",
            fontName: "Baskerville",
            category: .serif,
            previewText: "Refined grace"
        ),
        CustomFont(
            id: "times",
            displayName: "Times New Roman",
            fontName: "TimesNewRomanPSMT",
            category: .serif,
            previewText: "Traditional strength"
        ),

        // MARK: Sans Serif Fonts - Modern, clean
        CustomFont(
            id: "avenir",
            displayName: "Avenir",
            fontName: "Avenir-Medium",
            category: .sansSerif,
            previewText: "Modern clarity"
        ),
        CustomFont(
            id: "avenir-light",
            displayName: "Avenir Light",
            fontName: "Avenir-Light",
            category: .sansSerif,
            previewText: "Light and airy"
        ),
        CustomFont(
            id: "avenir-heavy",
            displayName: "Avenir Heavy",
            fontName: "Avenir-Heavy",
            category: .sansSerif,
            previewText: "Strong presence"
        ),
        CustomFont(
            id: "futura",
            displayName: "Futura",
            fontName: "Futura-Medium",
            category: .sansSerif,
            previewText: "Forward thinking"
        ),
        CustomFont(
            id: "gill-sans",
            displayName: "Gill Sans",
            fontName: "GillSans",
            category: .sansSerif,
            previewText: "British charm"
        ),
        CustomFont(
            id: "helvetica-neue",
            displayName: "Helvetica Neue",
            fontName: "HelveticaNeue",
            category: .sansSerif,
            previewText: "Swiss precision"
        ),
        CustomFont(
            id: "helvetica-neue-light",
            displayName: "Helvetica Light",
            fontName: "HelveticaNeue-Light",
            category: .sansSerif,
            previewText: "Minimal beauty"
        ),
        CustomFont(
            id: "optima",
            displayName: "Optima",
            fontName: "Optima-Regular",
            category: .sansSerif,
            previewText: "Elegant simplicity"
        ),

        // MARK: Display Fonts - Impactful, decorative
        CustomFont(
            id: "copperplate",
            displayName: "Copperplate",
            fontName: "Copperplate",
            category: .display,
            previewText: "BOLD IMPACT"
        ),
        CustomFont(
            id: "didot",
            displayName: "Didot",
            fontName: "Didot",
            category: .display,
            previewText: "High fashion"
        ),
        CustomFont(
            id: "rockwell",
            displayName: "Rockwell",
            fontName: "Rockwell-Regular",
            category: .display,
            previewText: "Solid foundation"
        ),
        CustomFont(
            id: "american-typewriter",
            displayName: "American Typewriter",
            fontName: "AmericanTypewriter",
            category: .display,
            previewText: "Vintage soul"
        ),

        // MARK: Handwritten Fonts - Personal, warm
        CustomFont(
            id: "bradley-hand",
            displayName: "Bradley Hand",
            fontName: "BradleyHandITCTT-Bold",
            category: .handwritten,
            previewText: "Personal touch"
        ),
        CustomFont(
            id: "marker-felt",
            displayName: "Marker Felt",
            fontName: "MarkerFelt-Wide",
            category: .handwritten,
            previewText: "Creative energy"
        ),
        CustomFont(
            id: "noteworthy",
            displayName: "Noteworthy",
            fontName: "Noteworthy-Light",
            category: .handwritten,
            previewText: "Gentle reminder"
        ),
        CustomFont(
            id: "snell-roundhand",
            displayName: "Snell Roundhand",
            fontName: "SnellRoundhand",
            category: .handwritten,
            previewText: "Graceful script"
        )
    ]

    /// Default font ID
    static let defaultFontID = "avenir"

    // MARK: - Private Init

    private init() {}

    // MARK: - Methods

    /// Get font by ID, falls back to default if not found
    func font(for id: String) -> CustomFont {
        availableFonts.first { $0.id == id } ?? defaultFont
    }

    /// The default font
    var defaultFont: CustomFont {
        availableFonts.first { $0.id == Self.defaultFontID } ?? availableFonts[0]
    }

    /// Get all fonts in a category
    func fonts(in category: FontCategory) -> [CustomFont] {
        availableFonts.filter { $0.category == category }
    }

    /// Create a Font for widget use (static helper for widget extension)
    static func widgetFont(fontID: String, size: CGFloat, weight: Font.Weight = .medium) -> Font {
        let manager = FontManager.shared
        let customFont = manager.font(for: fontID)
        return customFont.font(size: size, weight: weight)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension FontManager {
    /// Sample text for previewing fonts
    static let sampleQuote = "You weren't put here to be average"

    /// All fonts for preview purposes
    static var previewFonts: [CustomFont] {
        FontManager.shared.availableFonts
    }
}
#endif
