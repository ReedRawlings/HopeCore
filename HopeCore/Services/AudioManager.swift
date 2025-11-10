//
//  AudioManager.swift
//  HopeCore
//
//  Service - Audio Playback Management
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages playback of sleep sounds and focus sessions
//  - Supports streaming from remote URL or local file playback
//  - Background audio capability for uninterrupted listening
//  - Implements playback controls (play, pause, seek, volume)
//  - Handles audio session configuration for iOS
//  - Offline caching support for premium users
//

import Foundation
import AVFoundation
import Combine

/// Audio playback state
enum PlaybackState {
    case stopped
    case playing
    case paused
    case loading
    case error(String)
}

/// Manages audio playback throughout the app
/// Singleton service for centralized audio control
@Observable
class AudioManager: NSObject {
    static let shared = AudioManager()

    /// Current playback state
    var playbackState: PlaybackState = .stopped

    /// Currently playing track
    var currentTrack: AudioTrack?

    /// Current playback time in seconds
    var currentTime: TimeInterval = 0

    /// Total duration in seconds
    var duration: TimeInterval = 0

    /// Playback progress (0.0 to 1.0)
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    /// Playback speed (1.0 = normal, 1.25, 1.5, etc.)
    var playbackRate: Float = 1.0

    /// Volume (0.0 to 1.0)
    var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }

    // Private properties
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
        configureAudioSession()
    }

    // MARK: - Audio Session Configuration

    /// Configure audio session for background playback
    /// AGENT NOTE: Enables audio to continue when app is backgrounded
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Playback Controls

    /// Load and play an audio track
    /// - Parameter track: The audio track to play
    func playTrack(_ track: AudioTrack) {
        guard track.isAvailable else {
            playbackState = .error("Track not available")
            return
        }

        currentTrack = track
        playbackState = .loading

        // Determine URL (local file or remote stream)
        let url: URL?

        if track.isDownloaded, let localFilename = track.localFilename {
            // AGENT NOTE: Construct local file URL from filename
            url = getLocalAudioURL(filename: localFilename)
        } else if let remoteURLString = track.remoteURL {
            url = URL(string: remoteURLString)
        } else {
            url = nil
        }

        guard let audioURL = url else {
            playbackState = .error("Invalid audio URL")
            return
        }

        // Create player item and player
        let playerItem = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.rate = playbackRate

        // Setup time observation
        setupTimeObserver()

        // Setup playback notifications
        setupPlayerNotifications(playerItem: playerItem)

        // Start playback
        player?.play()
        playbackState = .playing
    }

    /// Resume playback
    func play() {
        guard player != nil else {
            if let track = currentTrack {
                playTrack(track)
            }
            return
        }

        player?.play()
        playbackState = .playing
    }

    /// Pause playback
    func pause() {
        player?.pause()
        playbackState = .paused
    }

    /// Stop playback and clear current track
    func stop() {
        player?.pause()
        player = nil
        currentTrack = nil
        currentTime = 0
        duration = 0
        playbackState = .stopped

        removeTimeObserver()
    }

    /// Seek to specific time
    /// - Parameter time: Time in seconds to seek to
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
    }

    /// Skip forward by seconds
    /// - Parameter seconds: Number of seconds to skip (default: 15)
    func skipForward(seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    /// Skip backward by seconds
    /// - Parameter seconds: Number of seconds to skip (default: 15)
    func skipBackward(seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    /// Set playback speed
    /// - Parameter rate: Playback rate (1.0 = normal, 1.25, 1.5, 2.0)
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        player?.rate = rate
    }

    // MARK: - Time Observation

    /// Setup periodic time observer for progress updates
    private func setupTimeObserver() {
        removeTimeObserver()

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds

            if let duration = self?.player?.currentItem?.duration.seconds,
               duration.isFinite {
                self?.duration = duration
            }
        }
    }

    /// Remove time observer
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    // MARK: - Player Notifications

    /// Setup notifications for player item events
    private func setupPlayerNotifications(playerItem: AVPlayerItem) {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.handlePlaybackFinished()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.playbackState = .error("Playback failed")
            }
            .store(in: &cancellables)
    }

    /// Handle playback completion
    private func handlePlaybackFinished() {
        playbackState = .stopped
        currentTime = 0

        // Update play count for track
        if let track = currentTrack {
            track.playCount += 1
            track.lastPlayedAt = Date()
        }

        // AGENT NOTE: Could auto-play next track or show completion UI
    }

    // MARK: - File Management

    /// Get local audio file URL
    /// AGENT NOTE: Implement proper file storage location
    private func getLocalAudioURL(filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first

        return documentsPath?.appendingPathComponent("Audio").appendingPathComponent(filename)
    }

    /// Download track for offline playback (premium feature)
    /// - Parameter track: Track to download
    func downloadTrack(_ track: AudioTrack) async throws {
        guard let remoteURLString = track.remoteURL,
              let remoteURL = URL(string: remoteURLString) else {
            throw AudioError.invalidURL
        }

        // AGENT NOTE: Implement actual download with progress tracking
        // For now, just a placeholder
        let (localURL, _) = try await URLSession.shared.download(from: remoteURL)

        let filename = "\(track.id.uuidString).mp3"
        let destinationURL = getLocalAudioURL(filename: filename)

        guard let destinationURL = destinationURL else {
            throw AudioError.saveFailed
        }

        // Move downloaded file to app directory
        try FileManager.default.moveItem(at: localURL, to: destinationURL)

        // Update track
        track.localFilename = filename
        track.isDownloaded = true
    }

    /// Delete downloaded track file
    /// - Parameter track: Track to delete
    func deleteDownloadedTrack(_ track: AudioTrack) throws {
        guard track.isDownloaded,
              let filename = track.localFilename,
              let fileURL = getLocalAudioURL(filename: filename) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
        track.isDownloaded = false
        track.localFilename = nil
    }
}

// MARK: - Audio Errors
enum AudioError: Error {
    case invalidURL
    case saveFailed
    case downloadFailed
    case fileNotFound

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid audio URL"
        case .saveFailed:
            return "Failed to save audio file"
        case .downloadFailed:
            return "Failed to download audio"
        case .fileNotFound:
            return "Audio file not found"
        }
    }
}
