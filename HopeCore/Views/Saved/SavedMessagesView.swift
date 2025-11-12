//
//  SavedMessagesView.swift
//  HopeCore
//
//  View - Saved Messages Library
//  Created for LLM-first development (Phase 2)
//
//  AGENT NOTES:
//  - Grid view of saved messages (isSaved = true)
//  - Sort options: newest, oldest, category
//  - Long-press to unsave messages
//  - Empty state if no saved messages
//  - Uses MessageCard component for consistency
//  - Integrates with MessageService for save/unsave actions
//

import SwiftUI
import SwiftData

struct SavedMessagesView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Query

    /// Query for saved messages only
    @Query(
        filter: #Predicate<Message> { $0.isSaved == true },
        sort: \Message.lastShownAt,
        order: .reverse
    ) private var savedMessages: [Message]

    // MARK: - State

    /// Current sort option
    @State private var sortOption: SortOption = .newest

    /// Selected message for detail view
    @State private var selectedMessage: Message?

    /// Show sort menu
    @State private var showSortMenu = false

    /// Message to share
    @State private var messageToShare: Message?

    // MARK: - Services

    private let messageService = MessageService.shared

    // MARK: - Computed Properties

    /// Sorted messages based on selected sort option
    private var sortedMessages: [Message] {
        switch sortOption {
        case .newest:
            return savedMessages.sorted { ($0.lastShownAt ?? Date.distantPast) > ($1.lastShownAt ?? Date.distantPast) }
        case .oldest:
            return savedMessages.sorted { ($0.lastShownAt ?? Date.distantPast) < ($1.lastShownAt ?? Date.distantPast) }
        case .category:
            return savedMessages.sorted { $0.categoryName < $1.categoryName }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BackgroundColors.primary
                    .ignoresSafeArea()

                if savedMessages.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        HapticFeedback.buttonPress()
                        dismiss()
                    }
                    .foregroundColor(TextColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    sortButton
                }
            }
            .sheet(item: $messageToShare) { message in
                ShareSheet(items: [generateShareText(for: message)])
            }
            .confirmationDialog("Sort by", isPresented: $showSortMenu) {
                Button("Newest First") {
                    sortOption = .newest
                    HapticFeedback.selection()
                }
                Button("Oldest First") {
                    sortOption = .oldest
                    HapticFeedback.selection()
                }
                Button("Category") {
                    sortOption = .category
                    HapticFeedback.selection()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header info
                HStack {
                    Text("\(savedMessages.count) saved messages")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.secondary)

                    Spacer()
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
                .padding(.top, Spacing.sm)

                // Grid of saved messages
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.sm),
                        GridItem(.flexible(), spacing: Spacing.sm)
                    ],
                    spacing: Spacing.md
                ) {
                    ForEach(sortedMessages) { message in
                        SavedMessageCard(
                            message: message,
                            onTap: {
                                selectMessage(message)
                            },
                            onUnsave: {
                                unsaveMessage(message)
                            },
                            onShare: {
                                shareMessage(message)
                            }
                        )
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    // MARK: - Sort Button

    private var sortButton: some View {
        Button(action: {
            HapticFeedback.buttonPress()
            showSortMenu = true
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 16))
                Text(sortOption.displayName)
                    .font(AppFonts.smallBody)
            }
            .foregroundColor(TextColors.primary)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(TextColors.tertiary)

            Text("No saved messages")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            Text("Save messages to build your collection")
                .supportingTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
        }
    }

    // MARK: - Actions

    /// Select message to view details
    private func selectMessage(_ message: Message) {
        HapticFeedback.messageTapped()
        selectedMessage = message
        // Could navigate to full message detail view
    }

    /// Remove message from saved collection
    private func unsaveMessage(_ message: Message) {
        messageService.unsaveMessage(message)
        try? modelContext.save()
        HapticFeedback.messageSaved()
    }

    /// Share message
    private func shareMessage(_ message: Message) {
        messageToShare = message
    }

    /// Generate share text for message
    private func generateShareText(for message: Message) -> String {
        var text = message.text
        text += "\n\nShared from HopeCore"
        return text
    }
}

// MARK: - Saved Message Card Component

/// Compact card for saved messages in grid view
struct SavedMessageCard: View {
    let message: Message
    let onTap: () -> Void
    let onUnsave: () -> Void
    let onShare: () -> Void

    @State private var showActions = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image or placeholder
                // Determine which URL to use based on presentation mode
                let imageURL: String? = {
                    switch message.presentationMode {
                    case .imageCard:
                        return message.imageCardURL
                    case .textOverlayBackground:
                        return message.backgroundImageURL
                    }
                }()

                if let imageURL = imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                        case .failure:
                            imagePlaceholder
                        case .empty:
                            imagePlaceholder
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }

                // Message text preview
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(message.text)
                        .font(AppFonts.smallBody)
                        .foregroundColor(TextColors.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    // Category badge
                    if !message.categoryName.isEmpty {
                        Text(message.categoryName)
                            .font(AppFonts.caption)
                            .foregroundColor(AccentColors.primary)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AccentColors.primary.opacity(0.1))
                            )
                    }
                }
                .padding(Spacing.sm)
            }
            .background(BackgroundColors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                    .stroke(AccentColors.primary, lineWidth: 2)
            )
        }
        .buttonStyle(SavedCardButtonStyle())
        .contextMenu {
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive, action: onUnsave) {
                Label("Unsave", systemImage: "heart.slash")
            }
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(BackgroundColors.secondary)
            .frame(height: 120)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundColor(TextColors.tertiary)
            )
    }
}

// MARK: - Saved Card Button Style

struct SavedCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: AnimationTiming.quick), value: configuration.isPressed)
    }
}

// MARK: - Sort Option Enum

enum SortOption: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case category = "category"

    var displayName: String {
        switch self {
        case .newest:
            return "Newest"
        case .oldest:
            return "Oldest"
        case .category:
            return "Category"
        }
    }
}


// MARK: - Preview

#Preview("Saved Messages - With Content") {
    SavedMessagesView()
        .modelContainer(for: [Message.self], inMemory: true)
}

#Preview("Saved Messages - Empty") {
    SavedMessagesView()
        .modelContainer(for: [Message.self], inMemory: true)
}
