//
//  Fonts.swift
//  HopeCore
//
//  Design System - Typography
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - SF Pro Display for large titles and hero messages
//  - SF Pro Text for body content and UI elements
//  - SF Pro Rounded for buttons (friendly feel)
//  - SF Mono for numeric data (timestamps, durations)
//  - Type scale follows designdoc.md specifications
//  - Message text uses 1.5x line height for readability
//

import SwiftUI

// MARK: - Font Families
/// System font families used throughout the app
struct FontFamilies {
    /// Large titles and hero text
    static let display = "SF Pro Display"

    /// Body text and UI elements
    static let text = "SF Pro Text"

    /// Buttons and friendly UI
    static let rounded = "SF Pro Rounded"

    /// Numeric data (timestamps, durations)
    static let mono = "SF Mono"
}

// MARK: - Typography System
/// Pre-defined text styles matching the design system
/// All sizes follow the 4pt grid system
struct AppFonts {
    // MARK: Display Sizes

    /// Screen titles, hero messages (28pt)
    static let display = Font.system(size: 28, weight: .bold, design: .default)

    /// Inspirational quotes (22pt, Display family)
    static let inspirationalQuote = Font.system(size: 22, weight: .semibold, design: .default)

    // MARK: Title Sizes

    /// Section headers (22pt)
    static let title = Font.system(size: 22, weight: .semibold, design: .default)

    /// Card headers (18pt)
    static let subtitle = Font.system(size: 18, weight: .medium, design: .default)

    // MARK: Body Sizes

    /// Primary content, message text (17pt)
    /// NOTE: Use with 1.5x line spacing for message cards
    static let largeBody = Font.system(size: 17, weight: .regular, design: .default)

    /// Supporting text, audio session names (15pt)
    static let regularBody = Font.system(size: 15, weight: .regular, design: .default)

    /// Metadata, timestamps (13pt)
    static let smallBody = Font.system(size: 13, weight: .regular, design: .default)

    /// Fine print, labels (11pt)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: Button Styles

    /// Primary buttons (15pt, Rounded)
    static let buttonPrimary = Font.system(size: 15, weight: .semibold, design: .rounded)

    /// Secondary buttons (13pt, Rounded)
    static let buttonSecondary = Font.system(size: 13, weight: .medium, design: .rounded)

    // MARK: Numeric/Mono Styles

    /// Timestamps and durations (13pt, Mono)
    static let timestamp = Font.system(size: 13, weight: .regular, design: .monospaced)

    /// Larger numeric displays (17pt, Mono)
    static let numericDisplay = Font.system(size: 17, weight: .medium, design: .monospaced)
}

// MARK: - Text Styles with Line Spacing
/// Pre-configured text styles that include proper line spacing
/// Use these for consistent typography throughout the app
extension View {
    /// Apply message text styling (17pt, 1.5x line height)
    /// - Returns: View with message text styling applied
    func messageTextStyle() -> some View {
        self
            .font(AppFonts.largeBody)
            .lineSpacing(8.5) // 1.5x line height for 17pt font
            .foregroundColor(TextColors.primary)
    }

    /// Apply inspirational quote styling (22pt, center-aligned)
    /// - Returns: View with inspirational quote styling applied
    func inspirationalQuoteStyle() -> some View {
        self
            .font(AppFonts.inspirationalQuote)
            .multilineTextAlignment(.center)
            .foregroundColor(TextColors.primary)
    }

    /// Apply audio session name styling (15pt, secondary color)
    /// - Returns: View with audio session styling applied
    func audioSessionStyle() -> some View {
        self
            .font(AppFonts.regularBody)
            .foregroundColor(TextColors.secondary)
    }

    /// Apply timestamp styling (13pt, SF Mono, tertiary color)
    /// - Returns: View with timestamp styling applied
    func timestampStyle() -> some View {
        self
            .font(AppFonts.timestamp)
            .foregroundColor(TextColors.tertiary)
    }

    /// Apply section header styling (22pt, semibold)
    /// - Returns: View with section header styling applied
    func sectionHeaderStyle() -> some View {
        self
            .font(AppFonts.title)
            .foregroundColor(TextColors.primary)
    }

    /// Apply supporting text styling (15pt, secondary color)
    /// - Returns: View with supporting text styling applied
    func supportingTextStyle() -> some View {
        self
            .font(AppFonts.regularBody)
            .foregroundColor(TextColors.secondary)
    }
}
