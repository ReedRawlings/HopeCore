//
//  Colors.swift
//  HopeCore
//
//  Design System - Color Palette
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - All colors are defined according to designdoc.md specifications
//  - Rose/magenta (#EC4899) is the primary accent for hopecore messaging
//  - Emerald (#10B981) is used for progress and growth indicators
//  - Dark backgrounds (#0A0E14) maintain the calm, spacious feeling
//  - Glass materials (blur effects) are preferred over solid colors for cards
//

import SwiftUI
import UIKit

// MARK: - Background Colors
/// Screen and surface background colors
/// These provide the dark, calm foundation for the app
struct BackgroundColors {
    /// Main screen backgrounds - deepest dark (#0A0E14)
    static let primary = Color(hex: "#0A0E14")

    /// Nested backgrounds, modals (#0F1419)
    static let secondary = Color(hex: "#0F1419")

    /// Text input fields (#1C2128)
    static let tertiary = Color(hex: "#1C2128")

    /// Chat/cards - elevated surfaces (#161B22)
    static let elevated = Color(hex: "#161B22")
}

// MARK: - Accent Colors
/// Primary and semantic accent colors
/// Rose represents warmth and possibility, emerald represents growth
struct AccentColors {
    // Primary - Hopecore State
    /// Rose/magenta - warmth, possibility (#EC4899)
    static let primary = Color(hex: "#EC4899")

    /// Lighter rose for highlights (#F472B6)
    static let primaryLight = Color(hex: "#F472B6")

    /// Darker rose for depth (#BE185D)
    static let primaryDark = Color(hex: "#BE185D")

    // Secondary - Supportive
    /// Emerald - growth, resilience (#10B981)
    static let secondary = Color(hex: "#10B981")

    /// Lighter emerald (#34D399)
    static let secondaryLight = Color(hex: "#34D399")

    // Semantic
    /// Progress indicator color (emerald)
    static let success = Color(hex: "#10B981")

    /// Amber - inspiring moments (#F59E0B)
    static let warmth = Color(hex: "#F59E0B")

    /// Gray - neutral info (#6B7280)
    static let neutral = Color(hex: "#6B7280")
}

// MARK: - Text Colors
/// Text and content colors
/// Hierarchy: primary (white) > secondary (light gray) > tertiary (darker gray)
struct TextColors {
    /// Main content (#FFFFFF)
    static let primary = Color(hex: "#FFFFFF")

    /// Supporting text (#9CA3AF)
    static let secondary = Color(hex: "#9CA3AF")

    /// Labels, metadata (#6B7280)
    static let tertiary = Color(hex: "#6B7280")

    /// Text on bright backgrounds (#0A0E14)
    static let inverse = Color(hex: "#0A0E14")

    /// Hopecore messaging accent (#EC4899)
    static let hopeful = Color(hex: "#EC4899")

    /// Achievement text (#10B981)
    static let success = Color(hex: "#10B981")
}

// MARK: - Material Styles
/// Glass and blur effect styles for depth
/// These create visual hierarchy without using shadows
struct MaterialStyles {
    /// Ultra-thin material for message cards and primary content
    static let ultraThin = Material.ultraThinMaterial

    /// Regular material for modals and sheets
    static let regular = Material.regularMaterial

    /// Thin material for overlays
    static let thin = Material.thinMaterial
}

// MARK: - Color Extension for Hex Support
extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (e.g., "#EC4899")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor Extension for Hex Support
extension UIColor {
    /// Initialize a UIColor from a hex string
    /// - Parameter hex: Hex color string (e.g., "#EC4899")
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
