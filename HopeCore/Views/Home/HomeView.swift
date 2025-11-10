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
//  - Overlay controls for save/share actions
//  - Settings icon in top right
//  - Music icon to open audio player overlay
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

    /// Show share sheet
    @State private var showShareSheet = false

    /// Message to share
    @State private var messageToShare: Message?

    /// Loading state
    @State private var isLoading = true

    // MARK: - Services

    /// Access message service for loading messages
    /// AGENT NOTE: MessageService should be injected or accessed as singleton
    /// For now, create instance here
    private let messageService = MessageService()

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

            // Top overlay with controls
            topControls

            // Audio player overlay
            if showAudioPlayer {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showAudioPlayer = false
                        }
                    }

                // AGENT NOTE: AudioPlayerOverlay component to be created
                // Placeholder for now
                VStack {
                    Spacer()
                    audioPlayerPlaceholder
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showSettings) {
            // AGENT NOTE: SettingsView to be created
            Text("Settings View")
                .presentationDetents([.medium, .large])
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

    private var mainContent: View {
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
                        // AGENT NOTE: Could navigate to full-screen message detail view
                        HapticFeedback.messageTapped()
                    }
                )
                .padding(.horizontal, ScreenLayout.horizontalMargin)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: currentIndex) { oldValue, newValue in
            handleIndexChange(oldValue: oldValue, newValue: newValue)
        }
    }

    // MARK: - Top Controls

    private var topControls: View {
        VStack {
            HStack {
                // App Title
                Text("HopeCore")
                    .font(AppFonts.title)
                    .foregroundColor(TextColors.primary)

                Spacer()

                // Music Button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showAudioPlayer.toggle()
                    }
                    HapticFeedback.buttonPress()
                }) {
                    Image(systemName: "music.note")
                        .font(.system(size: 24))
                        .foregroundColor(TextColors.primary)
                        .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                }

                // Settings Button
                Button(action: {
                    showSettings = true
                    HapticFeedback.buttonPress()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundColor(TextColors.primary)
                        .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)
            .padding(.top, ScreenLayout.topMargin)

            Spacer()
        }
    }

    // MARK: - Loading View

    private var loadingView: View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .tint(AccentColors.primary)
            Text("Loading messages...")
                .supportingTextStyle()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: View {
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

    // MARK: - Audio Player Placeholder

    /// Placeholder for audio player overlay
    /// AGENT NOTE: Replace with AudioPlayerOverlay component
    private var audioPlayerPlaceholder: View {
        VStack(spacing: Spacing.md) {
            // Header
            HStack {
                Text("Audio Player")
                    .font(AppFonts.subtitle)
                    .foregroundColor(TextColors.primary)

                Spacer()

                Button(action: {
                    withAnimation {
                        showAudioPlayer = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(TextColors.secondary)
                }
            }
            .padding()

            // Placeholder content
            VStack(spacing: Spacing.lg) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(TextColors.tertiary)

                Text("Audio library coming soon")
                    .supportingTextStyle()
            }
            .frame(height: 200)
        }
        .frame(maxWidth: .infinity)
        .background(BackgroundColors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
        .padding()
    }

    // MARK: - Actions

    /// Load messages from MessageService
    private func loadMessages() {
        isLoading = true

        // AGENT NOTE: This should fetch messages based on user tier and preferences
        // For now, load sample messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages = Message.sampleMessages
            isLoading = false
        }

        // TODO: Integrate with MessageService
        // Task {
        //     messages = await messageService.getTodaysMessages()
        //     isLoading = false
        // }
    }

    /// Handle index change for message viewing
    private func handleIndexChange(oldValue: Int, newValue: Int) {
        // Haptic feedback on scroll
        HapticFeedback.cardSwipe()

        // Mark message as shown
        guard newValue < messages.count else { return }
        let message = messages[newValue]

        // AGENT NOTE: Track message views
        // messageService.markAsShown(message)

        // Pre-fetch next images
        prefetchImages(around: newValue)
    }

    /// Pre-fetch images around current index
    private func prefetchImages(around index: Int) {
        // Pre-fetch previous, current, and next images
        let indicesToPrefetch = [index - 1, index, index + 1]

        for i in indicesToPrefetch {
            guard i >= 0 && i < messages.count else { continue }
            let message = messages[i]

            // AGENT NOTE: Use ImageCacheManager to prefetch
            // if let imageURL = message.imageURL {
            //     ImageCacheManager.shared.prefetchImage(url: imageURL)
            // }
        }
    }

    /// Toggle save state for message
    private func toggleSaveMessage(_ message: Message) {
        // Find message in array and toggle saved state
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].isSaved.toggle()

            // AGENT NOTE: Persist to SwiftData
            // try? modelContext.save()
        }
    }

    /// Share message
    private func shareMessage(_ message: Message) {
        messageToShare = message
    }

    /// Generate share text for message
    private func generateShareText(for message: Message) -> String {
        var text = message.text

        if let author = message.author {
            text += "\n\n— \(author)"
        }

        text += "\n\nShared from HopeCore"

        return text
    }
}

// MARK: - Share Sheet

/// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
