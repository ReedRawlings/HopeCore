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
//  - Supports deep linking from Lock Screen widget (initialMessageID)
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - Initialization Parameters
    
    /// Message ID to navigate to on launch (from widget deep link)
    /// AGENT NOTE: Set by AppRootView when app opens from widget tap
    var initialMessageID: UUID?

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

    /// Show share sheet
    @State private var showShareSheet = false

    /// Message to share
    @State private var messageToShare: Message?

    /// Loading state
    @State private var isLoading = true
    
    /// Tracks if we've already handled the initial navigation
    @State private var hasHandledInitialNavigation = false

    // MARK: - Services

    /// Access message service for loading messages
    /// AGENT NOTE: Using MessageService singleton for centralized message management
    private let messageService = MessageService.shared
    
    /// Deep link handler for widget navigation
    @StateObject private var deepLinkHandler = DeepLinkHandler.shared

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
        .sheet(item: $messageToShare) { message in
            // Share sheet
            ShareSheet(items: [generateShareText(for: message)])
        }
        .onAppear {
            loadMessages()
        }
        .onChange(of: deepLinkHandler.pendingMessageID) { oldValue, newValue in
            // Handle deep link when URL is opened (e.g., from widget tap)
            if let messageID = newValue, !messages.isEmpty {
                navigateToMessage(messageID)
            }
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
    /// AGENT NOTE: Loads messages from SwiftData, uses rotation-aware selection
    /// MessageService handles first-launch bundled quote loading and fallback internally
    /// Also handles navigation to deep-linked message from widget
    private func loadMessages() {
        isLoading = true

        // Load messages from SwiftData via MessageService
        // On first launch, MessageService loads bundled quotes from JSON
        // On subsequent launches, MessageService loads existing messages with user data
        messageService.loadMessages(from: modelContext)

        // Get rotation-aware messages (ensures no repeats until all seen)
        // Use a reasonable count for the feed (50 messages should be plenty)
        messages = messageService.getMessagesForFeed(count: 50)

        // Note: Fallback logic is now handled internally by MessageService
        // No need for duplicate fallback here

        isLoading = false
        
        // Handle deep link navigation from widget
        // AGENT NOTE: Navigates to specific message when app opens from widget tap
        handleInitialNavigation()

        // Pre-fetch initial images for smooth UX
        // AGENT NOTE: Prefetch first 3 images to improve initial scroll experience
        prefetchImages(around: currentIndex)
    }
    
    /// Navigate to deep-linked message from widget
    /// Called once after messages are loaded
    private func handleInitialNavigation() {
        guard !hasHandledInitialNavigation else { return }
        hasHandledInitialNavigation = true
        
        // Check both initialMessageID (from view creation) and pendingMessageID (from URL)
        let targetMessageID = initialMessageID ?? deepLinkHandler.pendingMessageID
        
        guard let messageID = targetMessageID else { return }
        
        navigateToMessage(messageID)
    }
    
    /// Navigate to a specific message by ID
    /// - Parameter messageID: UUID of the message to navigate to
    private func navigateToMessage(_ messageID: UUID) {
        // Find the message in our loaded messages
        if let targetIndex = messages.firstIndex(where: { $0.id == messageID }) {
            print("🔗 Deep link: Navigating to message at index \(targetIndex)")
            currentIndex = targetIndex
            
            // Clear the pending navigation in DeepLinkHandler
            deepLinkHandler.clearPendingNavigation()
            
            // Haptic feedback to indicate navigation
            HapticFeedback.buttonPress()
        } else {
            // Message not in current feed, try to find and add it
            if let message = messageService.getMessage(by: messageID) {
                // Prepend the target message to the feed so user sees it first
                messages.insert(message, at: 0)
                currentIndex = 0
                print("🔗 Deep link: Message found and added to feed")
                
                deepLinkHandler.clearPendingNavigation()
                HapticFeedback.buttonPress()
            } else {
                print("⚠️ Deep link: Message \(messageID) not found")
                // Still clear it to avoid retrying
                deepLinkHandler.clearPendingNavigation()
            }
        }
    }

    /// Handle index change for message viewing
    private func handleIndexChange(oldValue: Int, newValue: Int) {
        // Haptic feedback on scroll
        HapticFeedback.cardSwipe()

        // Mark message as shown
        guard newValue < messages.count else { return }
        let message = messages[newValue]

        // Track message and image views with MessageService (rotation-aware)
        // Pass modelContext so rotation state can be saved
        messageService.markAsShown(message, modelContext: modelContext)

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

                // Only prefetch imageCardURL images (backgrounds are bundled, not downloaded)
                if let imageURL = message.imageCardURL {
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
