//
//  MessageCard.swift
//  HopeCore
//
//  Component - Message Card Display (Dual Mode)
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Dual presentation modes:
//    1. Image Card Mode: Full-screen image with baked-in text (downloaded from R2)
//    2. Text Overlay Mode: User-selected background with text overlaid on top (bundled assets)
//  - Full-screen cards fill entire screen
//  - Glass morphism controls overlay at bottom (handled by HomeView)
//  - Image card images are downloaded from R2, background images are bundled with app
//

import SwiftUI
import SwiftData

/// Main message card component - dual presentation mode version
/// Displays either image card OR text overlay based on message presentation mode
struct MessageCard: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Query
    
    @Query private var preferences: [UserPreferences]
    
    // MARK: - Properties

    /// The message to display
    let message: Message

    /// Callback when save button is tapped
    var onSave: () -> Void

    /// Callback when share button is tapped
    var onShare: () -> Void

    /// Callback when card is tapped (optional)
    var onTap: (() -> Void)?
    
    // MARK: - Computed
    
    /// Get the background image to use for textOverlay mode
    /// Uses user's default background image from preferences, or falls back to default
    private var backgroundImageForOverlay: String {
        let userPrefs = preferences.first
        return userPrefs?.defaultBackgroundImage ?? Constants.Defaults.defaultBackgroundImage
    }

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
            // Background image (uses user's default background image from preferences)
            // All textOverlay quotes use the same user-selected background
            BundledImageView(imageName: backgroundImageForOverlay)
                .ignoresSafeArea()

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
    .modelContainer(for: [UserPreferences.self], inMemory: true)
}

#Preview("Text Mode") {
    MessageCard(
        message: Message.sampleMessages[3],
        onSave: {},
        onShare: {},
        onTap: {}
    )
    .background(BackgroundColors.primary)
    .modelContainer(for: [UserPreferences.self], inMemory: true)
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
    .modelContainer(for: [UserPreferences.self], inMemory: true)
}

// MARK: - Bundled Image View

/// View for loading bundled background images
/// Background images are installed with the app, not downloaded from R2
struct BundledImageView: View {
    let imageName: String
    
    var body: some View {
        Group {
            // Use SwiftUI Image directly for better performance with assets
            // Try loading as asset name (removes extension if present)
            if let assetName = sanitizedAssetName() {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback if bundled image not found
                BackgroundColors.primary
            }
        }
    }
    
    /// Get sanitized asset name for loading
    /// Extracts filename from URL or uses name directly
    /// AGENT NOTE: backgroundImageURL should be asset names (e.g., "image-1"), not URLs
    private func sanitizedAssetName() -> String? {
        // If it looks like a URL (starts with http:// or https://), don't try to load it
        // backgroundImageURL should only be asset names, not URLs
        if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            print("⚠️ backgroundImageURL should be an asset name, not a URL: \(imageName)")
            return nil
        }
        
        // Extract filename from URL if it's a full URL (legacy support)
        let filename: String
        if let url = URL(string: imageName), url.scheme != nil {
            filename = url.lastPathComponent.isEmpty ? imageName : url.lastPathComponent
        } else {
            filename = imageName
        }
        
        // Remove extension if present for asset lookup
        let nameWithoutExtension = (filename as NSString).deletingPathExtension
        
        // Verify the asset exists by checking if UIImage can load it
        // (SwiftUI Image doesn't have a way to check existence, so we use UIImage as a check)
        if UIImage(named: nameWithoutExtension) != nil {
            return nameWithoutExtension
        }
        
        // Try with original filename (in case it doesn't have an extension)
        if UIImage(named: filename) != nil {
            return filename
        }
        
        print("⚠️ Could not find asset named: \(imageName) (tried: \(nameWithoutExtension), \(filename))")
        return nil
    }
}
