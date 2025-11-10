//
//  Elevation.swift
//  HopeCore
//
//  Design System - Depth and Material Strategy
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Uses native iOS materials for depth (NO custom shadows)
//  - Glass materials (.ultraThinMaterial) for most cards
//  - Solid backgrounds for elements requiring focus (reading, playback)
//  - Material hierarchy creates calm visual depth
//  - NEVER use shadows in this app per design specifications
//

import SwiftUI

// MARK: - Material Strategy
/// Visual depth through native iOS blur materials
/// These replace traditional shadow-based elevation
struct Elevation {
    // MARK: Level 0 - Screen Background
    /// Base screen background (solid color)
    static let screenBackground = BackgroundColors.primary

    // MARK: Level 1 - Content Cards (Primary Pattern)
    /// Ultra-thin glass for message cards, browse cards
    /// Most common pattern - provides subtle depth
    static let cardMaterial = Material.ultraThinMaterial

    /// Alternative: Solid elevated background for text-heavy cards
    /// Used when glass creates reading interference
    static let cardSolid = BackgroundColors.elevated

    // MARK: Level 2 - Modals & Sheets
    /// Regular material for modals, more opaque than Level 1
    /// Used for settings sheets, pickers, overlays
    static let modalMaterial = Material.regularMaterial

    // MARK: Level 3 - Special Elements
    /// Audio player controls (solid for clarity)
    static let audioPlayerBackground = BackgroundColors.elevated

    /// Text input fields (solid)
    static let inputFieldBackground = BackgroundColors.tertiary

    /// Navigation bars (system standard)
    static let navigationBackground = BackgroundColors.primary
}

// MARK: - Material Application Guide
/// Reference for which material to use for each component type
/// AGENT NOTES: Consult this when creating new components
struct MaterialApplicationGuide {
    /// Message cards with image+text pairings
    /// Material: .ultraThinMaterial
    /// Reasoning: Primary focus; glass provides depth without distraction
    static let messageCardImageText = Elevation.cardMaterial

    /// Message cards with text-on-background
    /// Material: Solid (elevated)
    /// Reasoning: Reading comfort; solid avoids blur interference
    static let messageCardTextOnly = Elevation.cardSolid

    /// Audio browse cards
    /// Material: .ultraThinMaterial
    /// Reasoning: Scannable collection; consistent with message cards
    static let audioBrowseCard = Elevation.cardMaterial

    /// Audio now playing view
    /// Material: Solid (elevated)
    /// Reasoning: Player UI needs clarity during interaction
    static let audioPlayerView = Elevation.audioPlayerBackground

    /// Notification settings sheet
    /// Material: .regularMaterial
    /// Reasoning: Modal context; more opaque for form clarity
    static let settingsSheet = Elevation.modalMaterial

    /// Collection picker modal
    /// Material: .regularMaterial
    /// Reasoning: Selection context; modal treatment
    static let collectionPicker = Elevation.modalMaterial

    /// Primary buttons
    /// Material: None (solid color)
    /// Reasoning: Direct interaction; no material needed
    static let button = AccentColors.primary
}

// MARK: - Shadow Rules
/// IMPORTANT: This app uses NO shadows
/// All depth is created through material hierarchy and color
struct ShadowRules {
    /// Never use shadows on any component
    /// Glass materials provide sufficient visual hierarchy
    /// This maintains the calm, spacious design intent
    static let shadowOpacity: CGFloat = 0.0
    static let shadowRadius: CGFloat = 0.0
    static let shadowOffset: CGSize = .zero
}

// MARK: - View Extensions for Materials
extension View {
    /// Apply glass material background for cards
    /// Uses ultra-thin material for subtle depth
    /// - Returns: View with glass card material applied
    func glassCardBackground() -> some View {
        self.background(Elevation.cardMaterial)
    }

    /// Apply solid elevated background for text-focused cards
    /// - Returns: View with solid elevated background applied
    func solidCardBackground() -> some View {
        self.background(Elevation.cardSolid)
    }

    /// Apply modal material background for sheets and overlays
    /// More opaque than card material
    /// - Returns: View with modal material applied
    func modalBackground() -> some View {
        self.background(Elevation.modalMaterial)
    }

    /// Apply audio player background (solid)
    /// - Returns: View with audio player background applied
    func audioPlayerBackground() -> some View {
        self.background(Elevation.audioPlayerBackground)
    }

    /// Apply the standard card styling (glass + corner radius)
    /// Combines material, corner radius, and proper clipping
    /// - Returns: View styled as a standard glass card
    func standardCardStyle() -> some View {
        self
            .background(Elevation.cardMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    /// Apply solid card styling (elevated background + corner radius)
    /// For text-heavy content requiring reading clarity
    /// - Returns: View styled as a solid card
    func solidCardStyle() -> some View {
        self
            .background(Elevation.cardSolid)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }
}
