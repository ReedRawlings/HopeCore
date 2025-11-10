//
//  AudioPlayerComponent.swift
//  HopeCore
//
//  Component - Audio Player Overlay
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Full-screen modal audio player overlay
//  - Displays album art (240x240pt), title, and controls
//  - Real-time progress bar with seek capability
//  - Play/Pause button (56pt, rose accent)
//  - Playback speed selector (1x, 1.25x, 1.5x, 2.0x)
//  - Volume slider
//  - Close button to dismiss
//  - Observes AudioManager for playback state
//  - Haptic feedback on all interactions
//

import SwiftUI

struct AudioPlayerOverlay: View {
    // MARK: - Properties

    /// Callback when close button is tapped
    var onClose: () -> Void

    // MARK: - State

    /// Access to AudioManager
    @State private var audioManager = AudioManager.shared

    /// Available playback speeds
    private let playbackSpeeds: [Float] = [1.0, 1.25, 1.5, 2.0]

    /// Timer for progress updates
    @State private var progressTimer: Timer?

    // MARK: - Body

    var body: some View {
        ZStack {
            BackgroundColors.primary
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Close Button
                closeButton

                Spacer()

                // Album Art
                albumArt

                // Track Info
                trackInfo

                // Progress Slider
                progressSlider

                Spacer()

                // Playback Controls
                playbackControls

                // Speed Selector
                speedSelector

                // Volume Control
                volumeControl

                Spacer()
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)
            .padding(.vertical, ScreenLayout.topMargin)
        }
        .onAppear {
            startProgressTimer()
        }
        .onDisappear {
            stopProgressTimer()
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()

            Button(action: {
                HapticFeedback.buttonPress()
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(TextColors.primary)
                    .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
            }
        }
    }

    // MARK: - Album Art

    private var albumArt: some View {
        Group {
            if let thumbnailURL = audioManager.currentTrack?.thumbnailURL,
               let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        albumArtPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 240, height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
                    case .failure:
                        albumArtPlaceholder
                    @unknown default:
                        albumArtPlaceholder
                    }
                }
            } else {
                albumArtPlaceholder
            }
        }
    }

    private var albumArtPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                .fill(BackgroundColors.elevated)
                .frame(width: 240, height: 240)

            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundColor(TextColors.tertiary)
        }
    }

    // MARK: - Track Info

    private var trackInfo: some View {
        VStack(spacing: Spacing.xs) {
            if let track = audioManager.currentTrack {
                Text(track.title)
                    .font(AppFonts.inspirationalQuote)
                    .foregroundColor(TextColors.primary)
                    .multilineTextAlignment(.center)

                Text(track.audioType.displayName)
                    .audioSessionStyle()
            } else {
                Text("No track playing")
                    .supportingTextStyle()
            }
        }
    }

    // MARK: - Progress Slider

    private var progressSlider: some View {
        VStack(spacing: Spacing.xs) {
            // Slider
            Slider(
                value: Binding(
                    get: { audioManager.currentTime },
                    set: { newValue in
                        audioManager.seek(to: newValue)
                        HapticFeedback.audioSeeking()
                    }
                ),
                in: 0...max(audioManager.duration, 1)
            )
            .tint(AccentColors.success)

            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .timestampStyle()

                Spacer()

                Text(formatTime(audioManager.duration))
                    .timestampStyle()
            }
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: Spacing.xl) {
            // Skip Backward
            Button(action: {
                HapticFeedback.buttonPress()
                audioManager.skipBackward(seconds: 15)
            }) {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 32))
                    .foregroundColor(TextColors.secondary)
            }
            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)

            // Play/Pause
            Button(action: {
                HapticFeedback.audioPlayPause()
                togglePlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AccentColors.primary)
            }

            // Skip Forward
            Button(action: {
                HapticFeedback.buttonPress()
                audioManager.skipForward(seconds: 15)
            }) {
                Image(systemName: "goforward.15")
                    .font(.system(size: 32))
                    .foregroundColor(TextColors.secondary)
            }
            .frame(width: ComponentSpacing.minTapTarget, height: ComponentSpacing.minTapTarget)
        }
    }

    // MARK: - Speed Selector

    private var speedSelector: some View {
        HStack(spacing: Spacing.xs) {
            Text("Speed:")
                .supportingTextStyle()

            ForEach(playbackSpeeds, id: \.self) { speed in
                Button(action: {
                    HapticFeedback.selection()
                    audioManager.setPlaybackRate(speed)
                }) {
                    Text(formatSpeed(speed))
                        .font(AppFonts.buttonSecondary)
                        .foregroundColor(
                            audioManager.playbackRate == speed ?
                            AccentColors.primary : TextColors.secondary
                        )
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            audioManager.playbackRate == speed ?
                            AccentColors.primary.opacity(0.2) :
                            Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    // MARK: - Volume Control

    private var volumeControl: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(TextColors.tertiary)

                Slider(
                    value: Binding(
                        get: { Double(audioManager.volume) },
                        set: { newValue in
                            audioManager.volume = Float(newValue)
                        }
                    ),
                    in: 0...1
                )
                .tint(AccentColors.primary)

                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(TextColors.tertiary)
            }
        }
    }

    // MARK: - Computed Properties

    private var isPlaying: Bool {
        if case .playing = audioManager.playbackState {
            return true
        }
        return false
    }

    // MARK: - Helper Methods

    /// Format time interval to MM:SS
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Format playback speed
    private func formatSpeed(_ speed: Float) -> String {
        if speed == 1.0 {
            return "1×"
        } else {
            return String(format: "%.2f×", speed)
        }
    }

    /// Toggle play/pause
    private func togglePlayPause() {
        switch audioManager.playbackState {
        case .playing:
            audioManager.pause()
        case .paused, .stopped:
            audioManager.play()
        default:
            break
        }
    }

    /// Start timer to update progress
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Timer triggers view update via @Observable
        }
    }

    /// Stop progress timer
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

// MARK: - Simplified Audio Player Component

/// Compact audio player for home screen overlay
/// Simpler version of the full-screen player
struct CompactAudioPlayer: View {
    // MARK: - Properties

    var onClose: () -> Void
    var onExpand: () -> Void

    // MARK: - State

    @State private var audioManager = AudioManager.shared

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Play/Pause Button
            Button(action: {
                HapticFeedback.audioPlayPause()
                togglePlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AccentColors.primary)
            }

            // Track Info (tappable to expand)
            Button(action: {
                HapticFeedback.buttonPress()
                onExpand()
            }) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    if let track = audioManager.currentTrack {
                        Text(track.title)
                            .font(AppFonts.regularBody)
                            .foregroundColor(TextColors.primary)
                            .lineLimit(1)

                        Text(formatTime(audioManager.currentTime))
                            .timestampStyle()
                    } else {
                        Text("No track playing")
                            .supportingTextStyle()
                    }
                }
            }

            Spacer()

            // Close Button
            Button(action: {
                HapticFeedback.buttonPress()
                audioManager.stop()
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(TextColors.secondary)
            }
        }
        .padding()
        .background(BackgroundColors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    // MARK: - Computed Properties

    private var isPlaying: Bool {
        if case .playing = audioManager.playbackState {
            return true
        }
        return false
    }

    // MARK: - Helper Methods

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func togglePlayPause() {
        switch audioManager.playbackState {
        case .playing:
            audioManager.pause()
        case .paused, .stopped:
            audioManager.play()
        default:
            break
        }
    }
}

// MARK: - Preview

#Preview("Full Player") {
    AudioPlayerOverlay(onClose: {})
        .onAppear {
            // Simulate playing a track
            let track = AudioTrack.sampleTracks[0]
            AudioManager.shared.playTrack(track)
        }
}

#Preview("Compact Player") {
    VStack {
        Spacer()
        CompactAudioPlayer(onClose: {}, onExpand: {})
            .padding()
    }
    .background(BackgroundColors.primary)
    .onAppear {
        let track = AudioTrack.sampleTracks[0]
        AudioManager.shared.playTrack(track)
    }
}
