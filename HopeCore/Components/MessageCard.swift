//
//  MessageCard.swift
//  HopeCore
//
//  Component - Message Card Display
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Hero component of the app - displays hopecore message with image-text pairing
//  - Supports 4 presentation modes per designdoc.md:
//    1. imageText: Image at top, text below (most common)
//    2. textOnBackground: Text overlaid on image with opacity
//    3. split: Side-by-side 50/50 layout
//    4. minimal: Subtle background with prominent typography
//  - Uses glass materials (ultraThinMaterial) for depth
//  - Includes save/share actions with haptic feedback
//  - Animated save state with heart pulse effect
//  - Image loaded from ImageCacheManager for performance
//

import SwiftUI
import SwiftData

/// Main message card component
/// Displays hopecore messages with paired imagery in various presentation modes
struct MessageCard: View {
    // MARK: - Properties

    /// The message to display
    let message: Message

    /// Callback when save button is tapped
    var onSave: () -> Void

    /// Callback when share button is tapped
    var onShare: () -> Void

    /// Callback when card is tapped (optional full-screen view)
    var onTap: (() -> Void)?

    /// Whether to show action buttons
    var showActions: Bool = true

    // MARK: - State

    /// Animation state for save button
    @State private var saveAnimating = false

    /// Image cache manager for loading images
    /// AGENT NOTE: Using shared instance for centralized caching
    private let imageCacheManager = ImageCacheManager.shared

    // MARK: - Body

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            cardContent
                .savedStateStyle(isSaved: message.isSaved)
        }
        .buttonStyle(MessageCardButtonStyle())
    }

    // MARK: - Card Content

    @ViewBuilder
    private var cardContent: some View {
        switch MessagePresentationMode(rawValue: message.presentationMode) {
        case .imageText:
            imageTextLayout
        case .textOnBackground:
            textOnBackgroundLayout
        case .split:
            splitLayout
        case .minimal:
            minimalLayout
        case .none:
            // Fallback to imageText if mode is invalid
            imageTextLayout
        }
    }

    // MARK: - Presentation Mode 1: Image + Text

    /// Image at top, text below with clear separation
    private var imageTextLayout: some View {
        VStack(spacing: ComponentSpacing.imageTextGap) {
            // Image Section (top 60% max)
            // AGENT NOTE: Using AsyncImageView from ImageCacheManager for efficient caching
            if let imageURL = message.imageURL {
                AsyncImageView(urlString: imageURL)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: GridLayout.maxMessageImageHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }

            // Text Section
            Text(message.text)
                .messageTextStyle()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Author Attribution (if present)
            if let author = message.author {
                Text("— \(author)")
                    .supportingTextStyle()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Action Buttons
            if showActions {
                actionButtons
            }
        }
        .messageCardStyle()
    }

    // MARK: - Presentation Mode 2: Text on Background

    /// Text overlaid on background image with opacity
    private var textOnBackgroundLayout: some View {
        ZStack {
            // Background Image (opacity 0.4, blurred)
            // AGENT NOTE: Using AsyncImageView from ImageCacheManager for efficient caching
            if let imageURL = message.imageURL {
                AsyncImageView(urlString: imageURL)
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10)
                    .opacity(0.3)
            } else {
                BackgroundColors.secondary
            }

            // Text Content (centered, overlaid)
            VStack(spacing: Spacing.md) {
                Spacer()

                Text(message.text)
                    .messageTextStyle()
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

                if let author = message.author {
                    Text("— \(author)")
                        .supportingTextStyle()
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                }

                Spacer()

                // Action Buttons
                if showActions {
                    actionButtons
                }
            }
            .padding(ComponentSpacing.messageCardPadding)
        }
        .frame(minHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                .fill(MaterialStyles.ultraThin)
        )
    }

    // MARK: - Presentation Mode 3: Split Layout

    /// Side-by-side: 50% image, 50% text
    private var splitLayout: some View {
        HStack(spacing: Spacing.md) {
            // Left: Image (50%)
            // AGENT NOTE: Using AsyncImageView from ImageCacheManager for efficient caching
            if let imageURL = message.imageURL {
                AsyncImageView(urlString: imageURL)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }

            // Right: Text (50%)
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(message.text)
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)
                    .lineSpacing(6)

                if let author = message.author {
                    Text("— \(author)")
                        .supportingTextStyle()
                }

                Spacer()

                if showActions {
                    actionButtons
                }
            }
            .frame(maxWidth: .infinity)
        }
        .messageCardStyle()
    }

    // MARK: - Presentation Mode 4: Minimal

    /// Subtle background texture with prominent typography
    private var minimalLayout: some View {
        VStack(spacing: Spacing.md) {
            Spacer()

            Text(message.text)
                .inspirationalQuoteStyle()
                .multilineTextAlignment(.center)

            if let author = message.author {
                Text("— \(author)")
                    .supportingTextStyle()
            }

            Spacer()

            if showActions {
                actionButtons
            }
        }
        .frame(minHeight: 200)
        .solidMessageCardStyle()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: ComponentSpacing.buttonGap) {
            // Share Button
            Button(action: {
                HapticFeedback.messageShared()
                onShare()
            }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .font(AppFonts.buttonSecondary)
                .foregroundColor(TextColors.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSpacing.minTapTarget)
            }

            // Save Button
            Button(action: {
                saveAnimating = true
                HapticFeedback.messageSaved()
                onSave()

                // Reset animation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    saveAnimating = false
                }
            }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: message.isSaved ? "heart.fill" : "heart")
                        .foregroundColor(message.isSaved ? AccentColors.primary : TextColors.secondary)
                        .scaleEffect(saveAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: saveAnimating)
                    Text(message.isSaved ? "Saved" : "Save")
                }
                .font(AppFonts.buttonSecondary)
                .foregroundColor(message.isSaved ? AccentColors.primary : TextColors.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: ComponentSpacing.minTapTarget)
            }
        }
    }

    // MARK: - Image Placeholder

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(BackgroundColors.secondary)
            .frame(height: 200)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(TextColors.tertiary)
            )
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
    }
}

// MARK: - Button Style

/// Custom button style for message card interaction
/// Provides scale effect on press with spring animation
struct MessageCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Image + Text") {
    MessageCard(
        message: Message.sampleMessages[0],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .padding()
    .background(BackgroundColors.primary)
}

#Preview("Text on Background") {
    MessageCard(
        message: Message.sampleMessages[1],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .padding()
    .background(BackgroundColors.primary)
}

#Preview("Minimal") {
    MessageCard(
        message: Message.sampleMessages[3],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .padding()
    .background(BackgroundColors.primary)
}

#Preview("Saved State") {
    MessageCard(
        message: {
            var msg = Message.sampleMessages[0]
            msg.isSaved = true
            return msg
        }(),
        onSave: {},
        onShare: {}
    )
    .padding()
    .background(BackgroundColors.primary)
}
