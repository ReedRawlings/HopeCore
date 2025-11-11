//
//  AudioLibraryView.swift
//  HopeCore
//
//  View - Audio Library with Sleep & Focus Tracks
//  Created for LLM-first development (Phase 2)
//
//  AGENT NOTES:
//  - 2-column grid layout of audio tracks
//  - Separate sections for Sleep and Focus
//  - Shows duration with SF Mono font
//  - Icon for type (moon for sleep, brain for focus)
//  - Tap to play (opens AudioPlayerOverlay)
//  - Shows download status for offline tracks
//  - Integrates with AudioManager service
//

import SwiftUI
import SwiftData

struct AudioLibraryView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Query

    /// All audio tracks from SwiftData
    @Query(sort: \AudioTrack.sortOrder) private var allTracks: [AudioTrack]

    // MARK: - State

    /// Currently selected track (for player overlay)
    @State private var selectedTrack: AudioTrack?

    /// Show audio player overlay
    @State private var showAudioPlayer = false

    // MARK: - Services

    private let audioManager = AudioManager.shared

    // MARK: - Computed Properties

    /// Sleep tracks filtered from all tracks
    private var sleepTracks: [AudioTrack] {
        allTracks.filter { $0.trackType == AudioType.sleep.rawValue }
    }

    /// Focus tracks filtered from all tracks
    private var focusTracks: [AudioTrack] {
        allTracks.filter { $0.trackType == AudioType.focus.rawValue }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                BackgroundColors.primary
                    .ignoresSafeArea()

                if allTracks.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }

                // Audio player overlay
                if showAudioPlayer {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showAudioPlayer = false
                            }
                        }

                    VStack {
                        Spacer()
                        AudioPlayerOverlay(
                            onClose: {
                                withAnimation {
                                    showAudioPlayer = false
                                }
                            }
                        )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Audio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.buttonPress()
                        dismiss()
                    }
                    .foregroundColor(TextColors.primary)
                }
            }
        }
        .onAppear {
            loadSampleTracksIfNeeded()
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Sleep Sounds Section
                if !sleepTracks.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        sectionHeader(
                            title: "Sleep Sounds",
                            icon: "moon.fill",
                            count: sleepTracks.count
                        )

                        audioGrid(tracks: sleepTracks)
                    }
                }

                // Focus Sessions Section
                if !focusTracks.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        sectionHeader(
                            title: "Focus Sessions",
                            icon: "brain.head.profile",
                            count: focusTracks.count
                        )

                        audioGrid(tracks: focusTracks)
                    }
                }
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)
            .padding(.vertical, Spacing.lg)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AccentColors.primary)

            Text(title)
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            Text("(\(count))")
                .font(AppFonts.smallBody)
                .foregroundColor(TextColors.tertiary)

            Spacer()
        }
    }

    // MARK: - Audio Grid

    private func audioGrid(tracks: [AudioTrack]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ],
            spacing: Spacing.sm
        ) {
            ForEach(tracks) { track in
                AudioCard(
                    track: track,
                    onTap: {
                        playTrack(track)
                    }
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(TextColors.tertiary)

            Text("No audio tracks yet")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            Text("Audio content will be available soon")
                .supportingTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
        }
    }

    // MARK: - Actions

    /// Play selected track
    private func playTrack(_ track: AudioTrack) {
        HapticFeedback.audioPlayPause()

        selectedTrack = track
        audioManager.playTrack(track)

        withAnimation(.spring(response: 0.3)) {
            showAudioPlayer = true
        }
    }

    /// Load sample tracks if database is empty
    /// AGENT NOTE: For development only - remove when backend is ready
    private func loadSampleTracksIfNeeded() {
        guard allTracks.isEmpty else { return }

        // Insert sample tracks
        for track in AudioTrack.sampleTracks {
            modelContext.insert(track)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save sample tracks: \(error)")
        }
    }
}

// MARK: - Audio Card Component

/// Individual audio track card
struct AudioCard: View {
    let track: AudioTrack
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Thumbnail or placeholder
                ZStack {
                    Rectangle()
                        .fill(BackgroundColors.secondary)
                        .aspectRatio(1.0, contentMode: .fit)

                    // Icon
                    Image(systemName: track.audioType.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(TextColors.tertiary)

                    // Download badge
                    if track.isDownloaded {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(AccentColors.secondary)
                                    .padding(Spacing.xs)
                            }
                            Spacer()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))

                // Track title
                Text(track.title)
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Duration
                Text(track.formattedDuration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(TextColors.tertiary)
            }
        }
        .buttonStyle(AudioCardButtonStyle())
    }
}

// MARK: - Audio Card Button Style

struct AudioCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: AnimationTiming.quick), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Audio Library") {
    AudioLibraryView()
        .modelContainer(for: [AudioTrack.self], inMemory: true)
}

#Preview("Audio Card") {
    AudioCard(
        track: AudioTrack.sampleTracks[0],
        onTap: {}
    )
    .frame(width: 160)
    .padding()
    .background(BackgroundColors.primary)
}
