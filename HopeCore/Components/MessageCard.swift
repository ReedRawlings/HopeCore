//
//  MessageCard.swift
//  HopeCore
//
//  Component - Message Card Display (Dual Mode)
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Dual presentation modes:
//    1. Image Card Mode: Full-screen image with baked-in text (R2 only)
//    2. Text Overlay Mode: User-selected background with text overlaid on top (R2 only)
//  - Full-screen cards fill entire screen
//  - Glass morphism controls overlay at bottom (handled by HomeView)
//  - All images must be from R2 (no bundled assets)
//

import SwiftUI
import SwiftData

/// Main message card component - dual presentation mode version
/// Displays either image card OR text overlay based on message presentation mode
struct MessageCard: View {
    // MARK: - Properties

    /// The message to display
    let message: Message

    /// Callback when save button is tapped
    var onSave: () -> Void

    /// Callback when share button is tapped
    var onShare: () -> Void

    /// Callback when card is tapped (optional)
    var onTap: (() -> Void)?

    // MARK: - Body

    var body: some View {
        ZStack {
            switch message.presentationMode {
            case .imageCard:
                imageCardPresentation

            case .textOverlayBackground:
                textOverlayPresentation
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            onTap?()
        }
    }

    // MARK: - Image Card Mode (Full-screen image with baked-in text)

    private var imageCardPresentation: some View {
        ZStack {
            if let imageURL = message.imageCardURL {
                AsyncImageView(urlString: imageURL)
                    .ignoresSafeArea()
            } else {
                // Fallback to solid color if no image URL provided
                BackgroundColors.primary
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Text Overlay Mode (Background with text overlay)

    private var textOverlayPresentation: some View {
        ZStack {
            // Background image
            if let backgroundURL = message.backgroundImageURL {
                AsyncImageView(urlString: backgroundURL)
                    .ignoresSafeArea()
            } else {
                // Fallback to solid color if no background URL provided
                BackgroundColors.primary
                    .ignoresSafeArea()
            }

            // Dark gradient overlay for text readability
            LinearGradient(
                colors: [.black.opacity(0.3), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Text content centered
            VStack {
                Spacer()
                Text(message.text)
                    .font(AppFonts.display)
                    .foregroundColor(TextColors.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                Spacer()
            }
        }
    }
}
// MARK: - Preview

#Preview("Image Mode") {
    MessageCard(
        message: Message.sampleMessages[0],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .background(BackgroundColors.primary)
}

#Preview("Text Mode") {
    MessageCard(
        message: Message.sampleMessages[3],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .background(BackgroundColors.primary)
}

#Preview("Saved State") {
    MessageCard(
        message: {
            let msg = Message.sampleMessages[0]
            var mutableMsg = msg
            mutableMsg.isSaved = true
            return mutableMsg
        }(),
        onSave: {},
        onShare: {}
    )
    .background(BackgroundColors.primary)
}
