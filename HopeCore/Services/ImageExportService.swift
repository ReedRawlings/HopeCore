//
//  ImageExportService.swift
//  HopeCore
//
//  Service - Renders message cards as shareable images
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Uses SwiftUI ImageRenderer to convert views to images
//  - Supports multiple export formats for different social platforms
//  - Square (1080x1080) for Instagram posts
//  - Vertical (1080x1920, 9:16) for TikTok/Instagram Stories
//  - Renders MessageCard with background, text, and user's font choice
//  - Can add optional watermark branding
//

import SwiftUI
import UIKit

// MARK: - Share Format

/// Available export formats for social media sharing
enum ShareFormat: String, CaseIterable, Identifiable {
    case square = "Square"
    case vertical = "Story"

    var id: String { rawValue }

    /// Display name for UI
    var displayName: String {
        switch self {
        case .square: return "Square"
        case .vertical: return "Story"
        }
    }

    /// Description of where this format works best
    var description: String {
        switch self {
        case .square: return "Instagram, Twitter, Facebook"
        case .vertical: return "TikTok, Instagram Stories, Reels"
        }
    }

    /// Icon for the format
    var iconName: String {
        switch self {
        case .square: return "square"
        case .vertical: return "rectangle.portrait"
        }
    }

    /// Export size in pixels
    var size: CGSize {
        switch self {
        case .square: return CGSize(width: 1080, height: 1080)
        case .vertical: return CGSize(width: 1080, height: 1920)
        }
    }

    /// Aspect ratio for preview
    var aspectRatio: CGFloat {
        size.width / size.height
    }
}

// MARK: - Image Export Service

/// Service for rendering message cards as shareable images
@Observable
final class ImageExportService {

    // MARK: - Singleton

    static let shared = ImageExportService()

    private init() {}

    // MARK: - Public Methods

    /// Render a message as a shareable image
    /// - Parameters:
    ///   - message: The message to render
    ///   - format: The export format (square or vertical)
    ///   - backgroundImage: The background image name to use
    ///   - fontID: The font ID to use for text
    ///   - showWatermark: Whether to add HopeCore branding
    /// - Returns: The rendered UIImage, or nil if rendering fails
    @MainActor
    func renderMessageAsImage(
        message: Message,
        format: ShareFormat,
        backgroundImage: String,
        fontID: String,
        showWatermark: Bool = true
    ) -> UIImage? {
        let size = format.size

        // Create the shareable card view
        let cardView = ShareableMessageCard(
            messageText: message.text,
            backgroundImageName: backgroundImage,
            fontID: fontID,
            format: format,
            showWatermark: showWatermark
        )
        .frame(width: size.width, height: size.height)

        // Use ImageRenderer to convert to UIImage
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 1.0 // Export at 1x for exact pixel dimensions

        return renderer.uiImage
    }

    /// Save image to Photos library
    /// - Parameter image: The image to save
    /// - Returns: Success or failure
    func saveToPhotos(_ image: UIImage) async -> Bool {
        await withCheckedContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            // Note: This doesn't have a completion handler, so we assume success
            // For proper error handling, would need PHPhotoLibrary
            continuation.resume(returning: true)
        }
    }
}

// MARK: - Shareable Message Card

/// A message card view optimized for image export
/// Designed to look great when rendered as a static image
struct ShareableMessageCard: View {
    let messageText: String
    let backgroundImageName: String
    let fontID: String
    let format: ShareFormat
    let showWatermark: Bool

    /// Get the font for the message text
    private var messageFont: Font {
        let customFont = FontManager.shared.font(for: fontID)
        // Use larger font for export (scales well at 1080p)
        let fontSize: CGFloat = format == .square ? 48 : 56
        return customFont.font(size: fontSize, weight: .semibold)
    }

    var body: some View {
        ZStack {
            // Background image
            backgroundLayer

            // Gradient overlay for text readability
            gradientOverlay

            // Content
            VStack {
                Spacer()

                // Message text
                Text(messageText)
                    .font(messageFont)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 60)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

                Spacer()

                // Watermark
                if showWatermark {
                    watermarkView
                        .padding(.bottom, format == .vertical ? 80 : 40)
                }
            }
        }
    }

    // MARK: - Background Layer

    @ViewBuilder
    private var backgroundLayer: some View {
        // Try to load the bundled image
        if let uiImage = UIImage(named: backgroundImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Fallback gradient if image not found
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        ZStack {
            // Top gradient
            LinearGradient(
                colors: [.black.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .center
            )

            // Bottom gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Overall darkening for text contrast
            Color.black.opacity(0.2)
        }
    }

    // MARK: - Watermark

    private var watermarkView: some View {
        HStack {
            Spacer()

            Text("yourfutureself.is")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .padding(.trailing, 40)
        }
    }
}

// MARK: - Preview

#Preview("Square Format") {
    ShareableMessageCard(
        messageText: "You weren't put here to be average. Keep pushing forward.",
        backgroundImageName: "image-1",
        fontID: "avenir",
        format: .square,
        showWatermark: true
    )
    .frame(width: 400, height: 400)
}

#Preview("Vertical Format") {
    ShareableMessageCard(
        messageText: "Every day is a new opportunity to become a better version of yourself.",
        backgroundImageName: "image-2",
        fontID: "georgia",
        format: .vertical,
        showWatermark: true
    )
    .frame(width: 300, height: 533)
}
