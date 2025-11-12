//
//  ImageCacheManager.swift
//  HopeCore
//
//  Service - Image Caching and Download
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Manages downloading and caching images from R2 Cloudflare
//  - Pre-loads 3 random images daily for smooth UX
//  - Caches message card images locally to reduce bandwidth
//  - Implements memory + disk caching strategy
//  - Handles image download with progress tracking
//  - Automatic cache cleanup to manage storage
//

import Foundation
import SwiftUI
import Combine

/// Manages image downloading and caching
/// Singleton service for centralized image management
@Observable
class ImageCacheManager {
    static let shared = ImageCacheManager()

    /// In-memory cache for quick access
    private var memoryCache: NSCache<NSString, UIImage>

    /// File manager for disk operations
    private let fileManager = FileManager.default

    /// Cache directory URL
    private var cacheDirectoryURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ImageCache")
    }

    /// Maximum disk cache size in bytes (100 MB)
    private let maxDiskCacheSize: Int = 100 * 1024 * 1024

    /// Maximum memory cache size in MB
    private let maxMemoryCacheSize: Int = 50

    private init() {
        // Configure memory cache
        memoryCache = NSCache<NSString, UIImage>()
        memoryCache.totalCostLimit = maxMemoryCacheSize * 1024 * 1024

        // Create cache directory if needed
        createCacheDirectoryIfNeeded()
    }

    // MARK: - Cache Directory Setup

    /// Create cache directory structure
    private func createCacheDirectoryIfNeeded() {
        guard let cacheURL = cacheDirectoryURL else { return }

        if !fileManager.fileExists(atPath: cacheURL.path) {
            try? fileManager.createDirectory(
                at: cacheURL,
                withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Image Retrieval

    /// Get image from cache or download if needed
    /// - Parameter urlString: Image URL string
    /// - Returns: UIImage if available, nil otherwise
    func getImage(from urlString: String) async -> UIImage? {
        let cacheKey = urlString as NSString

        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }

        // Check disk cache
        if let diskImage = loadImageFromDisk(urlString: urlString) {
            // Store in memory cache for faster access
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        // Download image
        return await downloadImage(from: urlString)
    }

    /// Download image from URL
    /// - Parameter urlString: Remote URL string
    /// - Returns: Downloaded UIImage or nil
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let image = UIImage(data: data) else {
                print("Failed to create image from data")
                return nil
            }

            // Cache the image
            await cacheImage(image, for: urlString)

            return image
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
            return nil
        }
    }

    /// Cache image in memory and disk
    /// - Parameters:
    ///   - image: UIImage to cache
    ///   - urlString: URL string as cache key
    private func cacheImage(_ image: UIImage, for urlString: String) async {
        let cacheKey = urlString as NSString

        // Store in memory cache
        memoryCache.setObject(image, forKey: cacheKey)

        // Store in disk cache
        await Task.detached {
            self.saveImageToDisk(image, urlString: urlString)
        }.value
    }

    // MARK: - Disk Operations

    /// Load image from disk cache
    /// - Parameter urlString: URL string as filename
    /// - Returns: Cached UIImage or nil
    private func loadImageFromDisk(urlString: String) -> UIImage? {
        guard let cacheURL = cacheDirectoryURL else { return nil }

        let filename = urlString.hashValue.description
        let fileURL = cacheURL.appendingPathComponent(filename)

        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return nil
        }

        return image
    }

    /// Save image to disk cache
    /// - Parameters:
    ///   - image: UIImage to save
    ///   - urlString: URL string as filename
    nonisolated private func saveImageToDisk(_ image: UIImage, urlString: String) {
        guard let cacheURL = cacheDirectoryURL,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }

        let filename = urlString.hashValue.description
        let fileURL = cacheURL.appendingPathComponent(filename)

        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Failed to save image to disk: \(error.localizedDescription)")
        }
    }

    // MARK: - Pre-loading

    /// Pre-load random images for today
    /// AGENT NOTE: Call this daily (morning) to cache 3 random message images
    /// - Parameter messages: Available messages to pre-load from
    func preloadDailyImages(from messages: [Message]) async {
        // Select 3 random messages with images
        let messagesWithImages = messages.filter { $0.imageCardURL != nil || $0.backgroundImageURL != nil }
        let randomMessages = messagesWithImages.shuffled().prefix(3)

        // Pre-load their images
        for message in randomMessages {
            if let imageCardURL = message.imageCardURL {
                _ = await getImage(from: imageCardURL)
                print("Pre-loaded image for message: \(message.id)")
            } else if let backgroundImageURL = message.backgroundImageURL {
                _ = await getImage(from: backgroundImageURL)
                print("Pre-loaded image for message: \(message.id)")
            }
        }
    }

    /// Pre-load specific message images
    /// - Parameter messages: Messages to pre-load
    func preloadImages(for messages: [Message]) async {
        for message in messages {
            if let imageCardURL = message.imageCardURL {
                _ = await getImage(from: imageCardURL)
            } else if let backgroundImageURL = message.backgroundImageURL {
                _ = await getImage(from: backgroundImageURL)
            }
        }
    }

    // MARK: - Cache Management

    /// Clear memory cache
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    /// Clear disk cache
    func clearDiskCache() {
        guard let cacheURL = cacheDirectoryURL else { return }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: nil
            )

            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }

            print("Disk cache cleared")
        } catch {
            print("Failed to clear disk cache: \(error.localizedDescription)")
        }
    }

    /// Get current disk cache size in bytes
    func getDiskCacheSize() -> Int {
        guard let cacheURL = cacheDirectoryURL else { return 0 }

        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: [.fileSizeKey]
            )

            let totalSize = fileURLs.reduce(0) { size, fileURL in
                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                return size + fileSize
            }

            return totalSize
        } catch {
            print("Failed to calculate cache size: \(error.localizedDescription)")
            return 0
        }
    }

    /// Clean up old cache files if size exceeds limit
    func cleanupOldCacheIfNeeded() {
        let currentSize = getDiskCacheSize()

        guard currentSize > maxDiskCacheSize else { return }

        guard let cacheURL = cacheDirectoryURL else { return }

        do {
            // Get files sorted by modification date
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
            ).sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                return date1 < date2
            }

            // Delete oldest files until under limit
            var totalSize = currentSize
            for fileURL in fileURLs {
                guard totalSize > maxDiskCacheSize else { break }

                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                try fileManager.removeItem(at: fileURL)
                totalSize -= fileSize

                print("Deleted old cache file: \(fileURL.lastPathComponent)")
            }
        } catch {
            print("Failed to cleanup cache: \(error.localizedDescription)")
        }
    }
}

// MARK: - SwiftUI AsyncImage Extension
/// Convenience extension for loading cached images in SwiftUI
extension ImageCacheManager {
    /// Load image asynchronously for SwiftUI
    /// - Parameter urlString: Image URL string
    /// - Returns: Image view
    @MainActor
    func asyncImage(from urlString: String) -> some View {
        AsyncImageView(urlString: urlString)
    }
}

/// SwiftUI view for async image loading with caching
struct AsyncImageView: View {
    let urlString: String

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .task {
            image = await ImageCacheManager.shared.getImage(from: urlString)
            isLoading = false
        }
    }
}
