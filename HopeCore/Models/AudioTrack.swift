//
//  AudioTrack.swift
//  HopeCore
//
//  Data Model - Audio Content
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Two types: sleep sounds (10-15 min) and focus sessions (5-30 min)
//  - Audio files stored locally or streamed from backend
//  - Offline playback supported via local caching
//  - Simple, minimal audio library (not competing with Calm)
//  - Player state managed by AudioManager service
//

import Foundation
import SwiftData

/// Audio track for sleep or focus sessions
/// Supports both streaming and offline playback
@Model
final class AudioTrack {
    /// Unique identifier
    var id: UUID

    /// Track title (e.g., "Ocean Waves", "Morning Focus")
    var title: String

    /// Track description
    var trackDescription: String?

    /// Audio type: "sleep" or "focus"
    var trackType: String

    /// Duration in seconds
    var durationSeconds: Int

    /// Remote URL for streaming (if not cached locally)
    var remoteURL: String?

    /// Local filename (if downloaded for offline)
    var localFilename: String?

    /// Thumbnail image URL (optional)
    var thumbnailURL: String?

    /// Whether track is downloaded for offline playback
    var isDownloaded: Bool

    /// File size in bytes (for download management)
    var fileSizeBytes: Int?

    /// Number of times this track has been played
    var playCount: Int

    /// Last played timestamp
    var lastPlayedAt: Date?

    /// Sort order for display
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        title: String,
        trackDescription: String? = nil,
        trackType: String,
        durationSeconds: Int,
        remoteURL: String? = nil,
        localFilename: String? = nil,
        thumbnailURL: String? = nil,
        isDownloaded: Bool = false,
        fileSizeBytes: Int? = nil,
        playCount: Int = 0,
        lastPlayedAt: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.trackDescription = trackDescription
        self.trackType = trackType
        self.durationSeconds = durationSeconds
        self.remoteURL = remoteURL
        self.localFilename = localFilename
        self.thumbnailURL = thumbnailURL
        self.isDownloaded = isDownloaded
        self.fileSizeBytes = fileSizeBytes
        self.playCount = playCount
        self.lastPlayedAt = lastPlayedAt
        self.sortOrder = sortOrder
    }
}

// MARK: - Audio Type Enum
/// Audio track categories
enum AudioType: String, CaseIterable {
    case sleep = "sleep"
    case focus = "focus"

    var displayName: String {
        switch self {
        case .sleep:
            return "Sleep Sounds"
        case .focus:
            return "Focus Sessions"
        }
    }

    var iconName: String {
        switch self {
        case .sleep:
            return "moon.fill"
        case .focus:
            return "brain.head.profile"
        }
    }

    var typicalDuration: String {
        switch self {
        case .sleep:
            return "10-15 min"
        case .focus:
            return "5-30 min"
        }
    }
}

// MARK: - Computed Properties
extension AudioTrack {
    /// Formatted duration string (e.g., "12:34")
    var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Whether track is available for playback (either downloaded or has remote URL)
    var isAvailable: Bool {
        return isDownloaded || remoteURL != nil
    }

    /// Audio type as enum
    var audioType: AudioType {
        return AudioType(rawValue: trackType) ?? .focus
    }
}

// MARK: - Sample Tracks
extension AudioTrack {
    /// Sample audio tracks for development and preview
    /// AGENT NOTE: Replace with actual content from backend/CMS
    static let sampleTracks: [AudioTrack] = [
        // Sleep Sounds
        AudioTrack(
            title: "Ocean Waves",
            trackDescription: "Gentle waves for deep relaxation",
            trackType: "sleep",
            durationSeconds: 900, // 15 min
            remoteURL: "https://r2.example.com/audio/ocean-waves.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/ocean.jpg",
            sortOrder: 1
        ),
        AudioTrack(
            title: "Rain on Leaves",
            trackDescription: "Soft rainfall in the forest",
            trackType: "sleep",
            durationSeconds: 720, // 12 min
            remoteURL: "https://r2.example.com/audio/rain-leaves.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/rain.jpg",
            sortOrder: 2
        ),
        AudioTrack(
            title: "Night Crickets",
            trackDescription: "Peaceful evening sounds",
            trackType: "sleep",
            durationSeconds: 600, // 10 min
            remoteURL: "https://r2.example.com/audio/crickets.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/night.jpg",
            sortOrder: 3
        ),

        // Focus Sessions
        AudioTrack(
            title: "Morning Focus",
            trackDescription: "Ambient tones for concentrated work",
            trackType: "focus",
            durationSeconds: 1800, // 30 min
            remoteURL: "https://r2.example.com/audio/morning-focus.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/focus.jpg",
            sortOrder: 4
        ),
        AudioTrack(
            title: "Deep Work",
            trackDescription: "Minimal soundscape for flow state",
            trackType: "focus",
            durationSeconds: 1500, // 25 min
            remoteURL: "https://r2.example.com/audio/deep-work.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/deepwork.jpg",
            sortOrder: 5
        ),
        AudioTrack(
            title: "Quick Sprint",
            trackDescription: "5-minute productivity burst",
            trackType: "focus",
            durationSeconds: 300, // 5 min
            remoteURL: "https://r2.example.com/audio/quick-sprint.mp3",
            thumbnailURL: "https://r2.example.com/thumbs/sprint.jpg",
            sortOrder: 6
        )
    ]
}
