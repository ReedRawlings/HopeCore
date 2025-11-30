//
//  ImageRotationTracker.swift
//  HopeCore
//
//  Service - Image Extraction and Identification for Rotation
//  Created for round-robin rotation system
//
//  AGENT NOTES:
//  - Extracts unique images from messages (both imageCardURL and backgroundImageURL)
//  - Generates consistent identifiers for images
//  - Tracks which images have been seen in rotation cycles
//  - Handles both R2 URLs and bundled asset names
//

import Foundation

/// Service to extract and track unique images from messages
/// Supports round-robin rotation by identifying all unique images
struct ImageRotationTracker {
    
    /// Extract unique image identifiers from messages
    /// Returns both imageCardURL (R2 URLs) and backgroundImageURL (asset names)
    /// - Parameter messages: Array of messages to extract images from
    /// - Returns: Set of unique image identifiers
    static func extractUniqueImages(from messages: [Message]) -> Set<String> {
        var imageIDs = Set<String>()
        
        for message in messages {
            // Extract imageCardURL (R2 URLs)
            if let imageCardURL = message.imageCardURL, !imageCardURL.isEmpty {
                // Normalize URL for consistent identification
                let normalizedURL = normalizeImageURL(imageCardURL)
                imageIDs.insert(normalizedURL)
            }
            
            // Extract backgroundImageURL (bundled asset names)
            if let backgroundImageURL = message.backgroundImageURL, !backgroundImageURL.isEmpty {
                // Use asset name directly as identifier
                imageIDs.insert(backgroundImageURL)
            }
        }
        
        return imageIDs
    }
    
    /// Extract image identifier from a message
    /// Returns the primary image identifier (imageCardURL takes precedence)
    /// - Parameter message: Message to extract image from
    /// - Returns: Image identifier string, or nil if message has no image
    static func extractImageID(from message: Message) -> String? {
        // Prefer imageCardURL over backgroundImageURL
        if let imageCardURL = message.imageCardURL, !imageCardURL.isEmpty {
            return normalizeImageURL(imageCardURL)
        }
        
        if let backgroundImageURL = message.backgroundImageURL, !backgroundImageURL.isEmpty {
            return backgroundImageURL
        }
        
        return nil
    }
    
    /// Normalize image URL for consistent identification
    /// Removes query parameters, fragments, and normalizes encoding
    /// - Parameter urlString: Raw URL string
    /// - Returns: Normalized URL string
    private static func normalizeImageURL(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else {
            // If URL parsing fails, return original string
            return urlString
        }
        
        // Remove query parameters and fragments for consistent identification
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        components?.fragment = nil
        
        // Return normalized URL string
        return components?.url?.absoluteString ?? urlString
    }
    
    /// Get all unique imageCardURL values from messages
    /// - Parameter messages: Array of messages
    /// - Returns: Set of normalized imageCardURL strings
    static func extractImageCardURLs(from messages: [Message]) -> Set<String> {
        var urls = Set<String>()
        
        for message in messages {
            if let imageCardURL = message.imageCardURL, !imageCardURL.isEmpty {
                urls.insert(normalizeImageURL(imageCardURL))
            }
        }
        
        return urls
    }
    
    /// Get all unique backgroundImageURL values from messages
    /// - Parameter messages: Array of messages
    /// - Returns: Set of backgroundImageURL asset names
    static func extractBackgroundImageURLs(from messages: [Message]) -> Set<String> {
        var assetNames = Set<String>()
        
        for message in messages {
            if let backgroundImageURL = message.backgroundImageURL, !backgroundImageURL.isEmpty {
                assetNames.insert(backgroundImageURL)
            }
        }
        
        return assetNames
    }
    
    /// Check if a message has an image
    /// - Parameter message: Message to check
    /// - Returns: True if message has either imageCardURL or backgroundImageURL
    static func messageHasImage(_ message: Message) -> Bool {
        return (message.imageCardURL != nil && !message.imageCardURL!.isEmpty) ||
               (message.backgroundImageURL != nil && !message.backgroundImageURL!.isEmpty)
    }
}

