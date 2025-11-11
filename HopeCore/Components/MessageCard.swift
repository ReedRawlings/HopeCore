//
//  MessageCard.swift
//  HopeCore
//
//  Component - Message Card Display (Simplified)
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Simplified architecture with two presentation modes:
//    1. If imageURL exists: Show full-screen image from R2 (image contains all content)
//    2. If imageURL is nil: Show text centered on dark background
//  - No complex presentation modes or conditionals
//  - Full-screen cards fill entire screen
//  - Glass morphism controls overlay at bottom (handled by HomeView)
//

import SwiftUI
import SwiftData

/// Main message card component - simplified version
/// Displays either full-screen image OR centered text on dark background
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
        if let imageURL = message.imageURL {
            // Full-screen image from R2
            AsyncImageView(urlString: imageURL)
                .ignoresSafeArea()
        } else if let bundledName = message.bundledImageName {
            // Bundled image from Assets
            Image(bundledName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            // Text-only on app background
            BackgroundColors.primary
                .ignoresSafeArea()
            
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onTapGesture {
        onTap?()
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
