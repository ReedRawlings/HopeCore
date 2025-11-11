//
//  BottomControlsOverlay.swift
//  HopeCore
//
//  Component - Bottom Glass Morphism Controls Overlay
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Glass morphism overlay positioned at bottom of screen
//  - Contains 4 control buttons: Saved Messages, Share, Music, Settings
//  - Uses .ultraThinMaterial for native Apple glass effect
//  - Respects safe area insets for proper positioning
//  - Button styling follows design system with 44pt tap targets
//

import SwiftUI

/// Bottom overlay with glass morphism effect containing app controls
struct BottomControlsOverlay: View {
    // MARK: - Bindings

    /// Show saved messages view
    @Binding var showSavedMessages: Bool

    /// Show audio player
    @Binding var showAudioPlayer: Bool

    /// Show settings
    @Binding var showSettings: Bool

    /// Callback when share button is tapped
    var onShare: () -> Void

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()

            // Glass morphism control bar
            HStack(spacing: Spacing.xl) {
                // Favorites/Heart Button
                Button(action: {
                    showSavedMessages = true
                    HapticFeedback.buttonPress()
                }) {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AccentColors.primary)
                            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                    }
                }

                // Share Button
                Button(action: {
                    HapticFeedback.messageShared()
                    onShare()
                }) {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 28))
                            .foregroundColor(TextColors.primary)
                            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                    }
                }

                // Music Button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showAudioPlayer.toggle()
                    }
                    HapticFeedback.buttonPress()
                }) {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "music.note")
                            .font(.system(size: 28))
                            .foregroundColor(TextColors.primary)
                            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                    }
                }

                // Settings Button
                Button(action: {
                    showSettings = true
                    HapticFeedback.buttonPress()
                }) {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(TextColors.primary)
                            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
            .padding(.horizontal, ScreenLayout.horizontalMargin)
            .padding(.bottom, Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Bottom Controls Overlay") {
    ZStack {
        // Background to show glass effect
        BackgroundColors.primary
            .ignoresSafeArea()

        // Sample content behind overlay
        VStack {
            Text("Content behind overlay")
                .foregroundColor(TextColors.primary)
        }

        // Overlay
        BottomControlsOverlay(
            showSavedMessages: .constant(false),
            showAudioPlayer: .constant(false),
            showSettings: .constant(false),
            onShare: {}
        )
    }
}
