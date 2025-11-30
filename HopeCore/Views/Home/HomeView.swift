//
//  HomeView.swift
//  HopeCore
//
//  View - Home Screen with Message Feed
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Main screen of the app with vertical scrolling message feed
//  - TikTok/Instagram-style vertical paging (one message at a time)
//  - Uses TabView with .page style for smooth vertical scrolling
//  - Bottom glass morphism overlay with controls (saved, share, music, settings)
//  - Full-screen message cards for maximum content visibility
//  - Pre-fetches images for smooth scrolling
//  - Tracks message views with MessageService
//  - Haptic feedback on scroll
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    /// Currently displayed message index
    @State private var currentIndex = 0

    /// Messages to display in feed
    @State private var messages: [Message] = []

    /// Show audio player overlay
    @State private var showAudioPlayer = false

    /// Show settings screen
    @State private var showSettings = false

    /// Show saved messages view
    @State private var showSavedMessages = false

    /// Show routines view
    @State private var showRoutines = false

    /// Show share sheet
    @State private var showShareSheet = false

    /// Message to share
    @State private var messageToShare: Message?

    /// Loading state
    @State private var isLoading = true

    // MARK: - Services

    /// Access message service for loading messages
    /// AGENT NOTE: Using MessageService singleton for centralized message management
    private let messageService = MessageService.shared

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            BackgroundColors.primary
                .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if messages.isEmpty {
                emptyStateView
            } else {
                mainContent
            }

            // Bottom overlay with controls
            BottomControlsOverlay(
                showSavedMessages: $showSavedMessages,
                showAudioPlayer: $showAudioPlayer,
                showSettings: $showSettings,
                showRoutines: $showRoutines,
                onShare: {
                    // Share current message
                    guard currentIndex < messages.count else { return }
                    shareMessage(messages[currentIndex])
                }
            )
        }
        .sheet(isPresented: $showAudioPlayer) {
            // Audio Library
            AudioLibraryView()
        }
        .sheet(isPresented: $showSettings) {
            // Settings View
            SettingsView()
        }
        .sheet(isPresented: $showSavedMessages) {
            // Saved Messages View
            SavedMessagesView()
        }
        .sheet(isPresented: $showRoutines) {
            // Routines View
            RoutineListView()
        }
        .sheet(item: $messageToShare) { message in
            // Share sheet
            ShareSheet(items: [generateShareText(for: message)])
        }
        .onAppear {
            loadMessages()
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                MessageCard(
                    message: message,
                    onSave: {
                        toggleSaveMessage(message)
                    },
                    onShare: {
                        shareMessage(message)
                    },
                    onTap: {
                        HapticFeedback.messageTapped()
                    }
                )
                .ignoresSafeArea()
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .onChange(of: currentIndex) { oldValue, newValue in
            handleIndexChange(oldValue: oldValue, newValue: newValue)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .tint(AccentColors.primary)
            Text("Loading messages...")
                .supportingTextStyle()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(AccentColors.primary)

            Text("No messages yet")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            Text("Check back soon for your daily inspiration")
                .supportingTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
        }
    }

    // MARK: - Actions

    /// Load messages from MessageService
    /// AGENT NOTE: Loads messages from SwiftData, uses filtered messages based on user preferences
    /// MessageService handles first-launch bundled quote loading and fallback internally
    private func loadMessages() {
        isLoading = true

        // Load messages from SwiftData via MessageService
        // On first launch, MessageService loads bundled quotes from JSON
        // On subsequent launches, MessageService loads existing messages with user data
        messageService.loadMessages(from: modelContext)

        // Get filtered messages (excludes demotivation messages from regular feed)
        messages = messageService.filteredMessages

        // Note: Fallback logic is now handled internally by MessageService
        // No need for duplicate fallback here

        isLoading = false

        // Pre-fetch initial images for smooth UX
        // AGENT NOTE: Prefetch first 3 images to improve initial scroll experience
        prefetchImages(around: 0)
    }

    /// Handle index change for message viewing
    private func handleIndexChange(oldValue: Int, newValue: Int) {
        // Haptic feedback on scroll
        HapticFeedback.cardSwipe()

        // Mark message as shown
        guard newValue < messages.count else { return }
        let message = messages[newValue]

        // Track message views with MessageService
        messageService.markAsShown(message)

        // Save to SwiftData
        try? modelContext.save()

        // Pre-fetch next images
        prefetchImages(around: newValue)
    }

    /// Pre-fetch images around current index
    /// AGENT NOTE: Pre-loads images for smooth scrolling experience
    private func prefetchImages(around index: Int) {
        // Pre-fetch previous, current, and next images
        let indicesToPrefetch = [index - 1, index, index + 1]

        Task {
            for i in indicesToPrefetch {
                guard i >= 0 && i < messages.count else { continue }
                let message = messages[i]

                // Use ImageCacheManager to prefetch images for smooth scrolling
                // Determine which URL to use based on presentation mode
                let imageURL: String?
                switch message.presentationMode {
                case .imageCard:
                    imageURL = message.imageCardURL
                case .textOverlayBackground:
                    imageURL = message.backgroundImageURL
                }

                if let imageURL = imageURL {
                    _ = await ImageCacheManager.shared.getImage(from: imageURL)
                }
            }
        }
    }

    /// Toggle save state for message
    private func toggleSaveMessage(_ message: Message) {
        // Toggle saved state via MessageService
        messageService.toggleSaved(message)

        // Persist to SwiftData
        try? modelContext.save()

        // Haptic feedback
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


// MARK: - Previews

#Preview("Home View") {
    HomeView()
        .modelContainer(for: [Message.self, UserPreferences.self], inMemory: true)
}

#Preview("Home View - Loading") {
    HomeView()
        .onAppear {
            // Show loading state
        }
        .modelContainer(for: [Message.self], inMemory: true)
}
