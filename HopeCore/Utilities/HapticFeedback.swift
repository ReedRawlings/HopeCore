//
//  HapticFeedback.swift
//  HopeCore
//
//  Utilities - Haptic Feedback System
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Provides tactile feedback for user interactions
//  - Three levels: light, medium, success
//  - Light for common actions (tap, play/pause)
//  - Medium for meaningful actions (save, share)
//  - Success for achievements (saved, milestone)
//  - Respects user preference (can be disabled)
//

import UIKit

/// Haptic feedback manager for consistent tactile responses
/// Use throughout the app for improved user experience
enum HapticFeedback {

    // MARK: - Feedback Generators

    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let successGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: - Feedback Methods

    /// Light haptic feedback for common actions
    /// Use for: message tap, audio play/pause, category switch
    static func light() {
        guard isHapticEnabled() else { return }
        lightGenerator.prepare()
        lightGenerator.impactOccurred()
    }

    /// Medium haptic feedback for meaningful actions
    /// Use for: save message, share action, collection create
    static func medium() {
        guard isHapticEnabled() else { return }
        mediumGenerator.prepare()
        mediumGenerator.impactOccurred()
    }

    /// Success haptic feedback for achievements
    /// Use for: message saved, collection created, milestone reached
    static func success() {
        guard isHapticEnabled() else { return }
        successGenerator.prepare()
        successGenerator.notificationOccurred(.success)
    }

    /// Error haptic feedback
    /// Use for: failed actions, validation errors
    static func error() {
        guard isHapticEnabled() else { return }
        successGenerator.prepare()
        successGenerator.notificationOccurred(.error)
    }

    /// Warning haptic feedback
    /// Use for: caution states, confirmations needed
    static func warning() {
        guard isHapticEnabled() else { return }
        successGenerator.prepare()
        successGenerator.notificationOccurred(.warning)
    }

    /// Selection haptic feedback
    /// Use for: picker changes, slider adjustments
    static func selection() {
        guard isHapticEnabled() else { return }
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    // MARK: - Compound Feedback Patterns

    /// Double tap feedback pattern
    /// Quick succession of two light impacts
    static func doubleTap() {
        guard isHapticEnabled() else { return }
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            light()
        }
    }

    /// Heart pulse feedback pattern
    /// Used when saving/favoriting messages
    static func heartPulse() {
        guard isHapticEnabled() else { return }
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            light()
        }
    }

    /// Button press feedback pattern
    /// Quick light feedback for button interactions
    static func buttonPress() {
        light()
    }

    /// Card swipe feedback pattern
    /// Used when swiping through message cards
    static func cardSwipe() {
        selection()
    }

    // MARK: - User Preference Check

    /// Check if haptic feedback is enabled in user preferences
    /// AGENT NOTE: Integrate with UserPreferences when available
    private static func isHapticEnabled() -> Bool {
        // Check system haptic capability
        guard UIDevice.current.supportsHaptics else {
            return false
        }

        // AGENT NOTE: Add user preference check here
        // For now, always return true
        // Example:
        // return UserPreferences.shared.hapticFeedbackEnabled
        return true
    }
}

// MARK: - UIDevice Extension
extension UIDevice {
    /// Check if device supports haptic feedback
    var supportsHaptics: Bool {
        // Haptic feedback available on iPhone 7 and later
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - View Extension for Haptic Feedback
import SwiftUI

extension View {
    /// Add haptic feedback on tap
    /// - Parameter style: Haptic style to use
    /// - Returns: View with haptic feedback
    func hapticFeedback(on style: HapticStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    switch style {
                    case .light:
                        HapticFeedback.light()
                    case .medium:
                        HapticFeedback.medium()
                    case .success:
                        HapticFeedback.success()
                    case .selection:
                        HapticFeedback.selection()
                    }
                }
        )
    }
}

/// Haptic feedback styles
enum HapticStyle {
    case light
    case medium
    case success
    case selection
}

// MARK: - Common Action Helpers
/// Pre-defined haptic patterns for common app actions
/// AGENT NOTE: Use these for consistency across the app
extension HapticFeedback {

    // Message Actions
    static func messageTapped() { light() }
    static func messageSaved() { heartPulse() }
    static func messageShared() { medium() }
    static func messageUnsaved() { light() }

    // Audio Actions
    static func audioPlayPause() { light() }
    static func audioCompleted() { success() }
    static func audioSeeking() { selection() }

    // Navigation Actions
    static func categoryChanged() { selection() }
    static func tabChanged() { light() }
    static func modalPresented() { light() }
    static func modalDismissed() { light() }

    // Settings Actions
    static func settingChanged() { selection() }
    static func notificationScheduled() { success() }
    static func purchaseCompleted() { success() }

    // Error Actions
    static func actionFailed() { error() }
    static func validationFailed() { warning() }
}
