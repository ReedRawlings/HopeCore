//
//  Spacing.swift
//  HopeCore
//
//  Design System - Spacing and Layout
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - All spacing values follow a 4pt grid base
//  - Screen margins are 20pt horizontal, 20pt top / 24pt bottom
//  - Card padding is generous (16-20pt) for breathing room
//  - Message cards use 24pt vertical padding for emphasis
//  - Consistent spacing creates a calm, spacious feeling
//

import SwiftUI

// MARK: - Spacing System
/// Standardized spacing values based on 4pt grid
/// All spacing in the app should use these values for consistency
struct Spacing {
    /// Extra small - Related elements (8pt)
    static let xs: CGFloat = 8

    /// Small - Card internal spacing (12pt)
    static let sm: CGFloat = 12

    /// Medium - Section spacing (16pt)
    static let md: CGFloat = 16

    /// Large - Screen margins (20pt)
    static let lg: CGFloat = 20

    /// Extra large - Major sections (24pt)
    static let xl: CGFloat = 24

    /// 2X large - Screen-level separation (32pt)
    static let xxl: CGFloat = 32

    /// 3X large - Hero spacing (48pt)
    static let xxxl: CGFloat = 48
}

// MARK: - Screen Layout
/// Specific spacing values for screen-level layouts
struct ScreenLayout {
    /// Horizontal screen margins (20pt)
    static let horizontalMargin: CGFloat = Spacing.lg

    /// Top screen margin (20pt)
    static let topMargin: CGFloat = Spacing.lg

    /// Bottom screen margin (24pt)
    static let bottomMargin: CGFloat = Spacing.xl

    /// Spacing between major sections (24pt)
    static let sectionSpacing: CGFloat = Spacing.xl

    /// Gap between cards in a grid (12pt)
    static let cardGap: CGFloat = Spacing.sm
}

// MARK: - Component Spacing
/// Spacing specific to individual components
struct ComponentSpacing {
    // Message Cards
    /// Message card padding (20pt)
    static let messageCardPadding: CGFloat = Spacing.lg

    /// Vertical padding for message cards (24pt for emphasis)
    static let messageCardVerticalPadding: CGFloat = Spacing.xl

    /// Gap between image and text in message card (16pt)
    static let imageTextGap: CGFloat = Spacing.md

    // Audio Components
    /// Audio component padding (16pt)
    static let audioComponentPadding: CGFloat = Spacing.md

    /// Compact audio player height (64pt)
    static let compactAudioPlayerHeight: CGFloat = 64

    // Buttons and Interactive Elements
    /// Minimum tap target size (44pt)
    static let minTapTarget: CGFloat = 44

    /// Primary button height (56pt)
    static let primaryButtonHeight: CGFloat = 56

    /// Gap between action buttons (12pt)
    static let buttonGap: CGFloat = Spacing.sm

    // Cards and Containers
    /// Standard card corner radius (16pt)
    static let cardCornerRadius: CGFloat = 16

    /// Small card corner radius (12pt)
    static let smallCornerRadius: CGFloat = 12

    /// Card border width when highlighted (2pt)
    static let cardBorderWidth: CGFloat = 2
}

// MARK: - Grid System
/// Layout parameters for grid-based content
struct GridLayout {
    /// Number of columns for message grid
    static let messageGridColumns = 2

    /// Standard aspect ratio for message thumbnails (4:3)
    static let thumbnailAspectRatio: CGFloat = 4/3

    /// Max height for full-screen message images (300pt)
    static let maxMessageImageHeight: CGFloat = 300

    /// Image section max height in card (60% of card)
    static let imageMaxHeightPercent: CGFloat = 0.6
}

// MARK: - View Extensions for Spacing
extension View {
    /// Apply standard screen margins (20pt horizontal, 20pt top, 24pt bottom)
    /// - Returns: View with screen margins applied
    func screenMargins() -> some View {
        self.padding(.horizontal, ScreenLayout.horizontalMargin)
            .padding(.top, ScreenLayout.topMargin)
            .padding(.bottom, ScreenLayout.bottomMargin)
    }

    /// Apply message card padding (20pt all sides)
    /// - Returns: View with message card padding applied
    func messageCardPadding() -> some View {
        self.padding(ComponentSpacing.messageCardPadding)
    }

    /// Apply standard card corner radius (16pt)
    /// - Returns: View with card corner radius applied
    func cardCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    /// Apply small corner radius (12pt)
    /// - Returns: View with small corner radius applied
    func smallCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
    }

    /// Apply section spacing between major sections (24pt)
    /// - Returns: View with section spacing applied
    func sectionSpacing() -> some View {
        self.padding(.vertical, ScreenLayout.sectionSpacing)
    }
}
