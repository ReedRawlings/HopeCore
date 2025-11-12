//
//  MessagePresentationMode.swift
//  HopeCore
//
//  Model - Presentation mode enum for messages
//  Created for dual-mode message display
//
//  AGENT NOTES:
//  - Determines how a message is displayed in the UI
//  - imageCard: Full-screen image with baked-in text
//  - textOverlayBackground: User-selected background with text overlaid on top
//

import Foundation

/// Determines how a HopeCore message is displayed in the feed
enum MessagePresentationMode: String, Codable {
    /// Full-screen image with baked-in text (hosted on R2 or bundled)
    case imageCard = "imageCard"

    /// User-selected background with text overlaid on top
    case textOverlayBackground = "textOverlay"
}
