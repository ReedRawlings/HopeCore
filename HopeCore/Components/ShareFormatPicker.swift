//
//  ShareFormatPicker.swift
//  HopeCore
//
//  Component - Share format selection sheet
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Lets users pick between Square (Instagram) and Vertical (Stories/TikTok) formats
//  - Allows customization of background and font before sharing
//  - Shows live preview of how the image will look
//  - Generates image using ImageExportService
//  - Presents share sheet with the generated image
//

import SwiftUI

/// Sheet for selecting share format and sharing message as image
struct ShareFormatPicker: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// The message to share
    let message: Message

    /// Initial background image from user preferences
    let initialBackgroundImage: String

    /// Initial font ID from user preferences
    let initialFontID: String

    // MARK: - State

    /// Selected format
    @State private var selectedFormat: ShareFormat = .square

    /// Selected background image (can be customized)
    @State private var selectedBackground: String = ""

    /// Selected font ID (can be customized)
    @State private var selectedFontID: String = ""

    /// Whether we're generating the image
    @State private var isGenerating = false

    /// Generated image for sharing
    @State private var generatedImage: UIImage?

    /// Show share sheet
    @State private var showShareSheet = false

    /// Show save confirmation
    @State private var showSaveConfirmation = false

    // MARK: - Init

    init(message: Message, backgroundImage: String, fontID: String) {
        self.message = message
        self.initialBackgroundImage = backgroundImage
        self.initialFontID = fontID
        // Initialize state with passed values
        _selectedBackground = State(initialValue: backgroundImage)
        _selectedFontID = State(initialValue: fontID)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColors.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Format selector
                        formatSelector

                        // Background picker
                        backgroundPicker

                        // Font picker
                        fontPicker

                        // Preview
                        previewSection

                        // Action buttons
                        actionButtons
                    }
                    .padding(.horizontal, ScreenLayout.horizontalMargin)
                    .padding(.vertical, Spacing.lg)
                }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TextColors.secondary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = generatedImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Saved to Photos", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    // MARK: - Format Selector

    private var formatSelector: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Format")
                .font(AppFonts.smallBody)
                .foregroundColor(TextColors.tertiary)

            HStack(spacing: Spacing.md) {
                ForEach(ShareFormat.allCases) { format in
                    formatButton(format)
                }
            }
        }
    }

    private func formatButton(_ format: ShareFormat) -> some View {
        Button(action: {
            HapticFeedback.selection()
            selectedFormat = format
        }) {
            VStack(spacing: Spacing.xs) {
                // Icon
                Image(systemName: format.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(selectedFormat == format ? AccentColors.primary : TextColors.secondary)

                // Name
                Text(format.displayName)
                    .font(AppFonts.smallBody)
                    .foregroundColor(selectedFormat == format ? TextColors.primary : TextColors.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .fill(selectedFormat == format ? AccentColors.primary.opacity(0.1) : BackgroundColors.elevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .stroke(selectedFormat == format ? AccentColors.primary : Color.clear, lineWidth: 2)
            )
        }
    }

    // MARK: - Background Picker

    private var backgroundPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Background")
                .font(AppFonts.smallBody)
                .foregroundColor(TextColors.tertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Constants.BackgroundImages.availableImages, id: \.self) { imageName in
                        Button(action: {
                            HapticFeedback.selection()
                            selectedBackground = imageName
                        }) {
                            BundledImageView(imageName: imageName)
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selectedBackground == imageName ? AccentColors.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Font Picker

    private var fontPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Font")
                .font(AppFonts.smallBody)
                .foregroundColor(TextColors.tertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(FontManager.shared.availableFonts) { font in
                        Button(action: {
                            HapticFeedback.selection()
                            selectedFontID = font.id
                        }) {
                            Text("Aa")
                                .font(font.font(size: 18))
                                .foregroundColor(selectedFontID == font.id ? AccentColors.primary : TextColors.secondary)
                                .frame(width: 50, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedFontID == font.id ? AccentColors.primary.opacity(0.1) : BackgroundColors.elevated)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selectedFontID == font.id ? AccentColors.primary : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                    }
                }
            }

            // Show selected font name
            Text(FontManager.shared.font(for: selectedFontID).displayName)
                .font(AppFonts.caption)
                .foregroundColor(TextColors.tertiary)
        }
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("Preview")
                .font(AppFonts.smallBody)
                .foregroundColor(TextColors.tertiary)

            // Scaled preview of the shareable card
            ShareableMessageCard(
                messageText: message.text,
                backgroundImageName: selectedBackground,
                fontID: selectedFontID,
                format: selectedFormat,
                showWatermark: true
            )
            .aspectRatio(selectedFormat.aspectRatio, contentMode: .fit)
            .frame(maxHeight: 300)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Spacing.md) {
            // Share button
            Button(action: shareImage) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Image")
                    }
                }
                .primaryButtonStyle()
            }
            .disabled(isGenerating)

            // Save to Photos button
            Button(action: saveToPhotos) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save to Photos")
                }
                .secondaryButtonStyle()
            }
            .disabled(isGenerating)
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Actions

    @MainActor
    private func shareImage() {
        isGenerating = true
        HapticFeedback.buttonPress()

        // Generate image with selected customizations
        if let image = ImageExportService.shared.renderMessageAsImage(
            message: message,
            format: selectedFormat,
            backgroundImage: selectedBackground,
            fontID: selectedFontID,
            showWatermark: true
        ) {
            generatedImage = image
            isGenerating = false
            showShareSheet = true
        } else {
            isGenerating = false
            generatedImage = nil
        }
    }

    @MainActor
    private func saveToPhotos() {
        isGenerating = true
        HapticFeedback.buttonPress()

        // Generate image with selected customizations
        if let image = ImageExportService.shared.renderMessageAsImage(
            message: message,
            format: selectedFormat,
            backgroundImage: selectedBackground,
            fontID: selectedFontID,
            showWatermark: true
        ) {
            Task {
                _ = await ImageExportService.shared.saveToPhotos(image)
                await MainActor.run {
                    isGenerating = false
                    showSaveConfirmation = true
                    HapticFeedback.success()
                }
            }
        } else {
            isGenerating = false
        }
    }
}

// MARK: - Preview

#Preview {
    ShareFormatPicker(
        message: Message.sampleMessages[0],
        backgroundImage: "image-1",
        fontID: "avenir"
    )
}
