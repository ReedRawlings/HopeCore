//
//  AnimationTiming.swift
//  HopeCore
//
//  Design System - Animation and Transitions
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Standard animation durations create consistent feel
//  - Spring animations for organic, natural movement
//  - Respect system Reduce Motion settings
//  - Animations should feel deliberate but not sluggish
//  - All timings align with iOS Human Interface Guidelines
//

import SwiftUI

// MARK: - Animation Timing
/// Standard animation durations for consistency
struct AnimationTiming {
    /// Immediate feedback (0.1s)
    static let instant: TimeInterval = 0.1

    /// Button press, quick interactions (0.2s)
    static let quick: TimeInterval = 0.2

    /// Most transitions, standard timing (0.3s)
    static let standard: TimeInterval = 0.3

    /// Modal entrance, deliberate movements (0.5s)
    static let deliberate: TimeInterval = 0.5

    /// Audio playback progress, slow updates (1.0s)
    static let slow: TimeInterval = 1.0
}

// MARK: - Animation Curves
/// Pre-defined animations for common use cases
struct AppAnimations {
    // MARK: Basic Curves

    /// Quick, snappy animation for buttons (0.2s easeOut)
    static let buttonPress = Animation.easeOut(duration: AnimationTiming.quick)

    /// Standard transition (0.3s easeInOut)
    static let standardTransition = Animation.easeInOut(duration: AnimationTiming.standard)

    /// Deliberate, smooth animation (0.5s easeInOut)
    static let deliberate = Animation.easeInOut(duration: AnimationTiming.deliberate)

    // MARK: Spring Animations

    /// Bouncy spring for playful interactions (0.4s spring)
    /// Used for save button, favorite actions
    static let bouncySpring = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)

    /// Standard spring for most UI elements (0.3s spring)
    /// Used for card entrance, sheet presentation
    static let standardSpring = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)

    /// Gentle spring for subtle movements (0.35s spring)
    /// Used for audio player appearance
    static let gentleSpring = Animation.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)

    // MARK: Special Cases

    /// Fade animation for content (0.3s with 0.1s delay)
    /// Used for text fade-in on message cards
    static let contentFadeIn = Animation.easeOut(duration: AnimationTiming.standard).delay(0.1)

    /// Color transition for state changes (0.2s easeOut)
    /// Used for save button color change
    static let colorTransition = Animation.easeOut(duration: AnimationTiming.quick)

    /// Scale animation for card tap (0.2s spring)
    /// Card scales from 1.0 → 0.97 → 1.0
    static let cardTapScale = Animation.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)
}

// MARK: - Transition Styles
/// Pre-configured transitions for view changes
struct AppTransitions {
    /// Slide in from bottom (modal presentation)
    static let slideUp = AnyTransition.move(edge: .bottom)
        .combined(with: .opacity)

    /// Slide in from right (navigation push)
    static let slideRight = AnyTransition.move(edge: .trailing)

    /// Fade transition (category switching)
    static let fade = AnyTransition.opacity

    /// Scale with fade (card appearance)
    static let scaleAndFade = AnyTransition.scale(scale: 0.9)
        .combined(with: .opacity)
}

// MARK: - Micro-Interactions
/// Specific animation parameters for common interactions
/// AGENT NOTES: Use these for consistent micro-interaction feel
struct MicroInteractions {
    // Message Card Tap
    /// Scale factor when card is pressed (0.97)
    static let cardPressScale: CGFloat = 0.97

    /// Duration for card tap animation (0.2s)
    static let cardTapDuration = AnimationTiming.quick

    // Save Button
    /// Heart icon scale animation: 0.8 → 1.2 → 1.0 (0.4s spring)
    static let heartPulseAnimation = AppAnimations.bouncySpring

    /// Color transition duration for save state (0.2s)
    static let saveColorDuration = AnimationTiming.quick

    // Audio Player
    /// Play/pause icon crossfade (0.15s)
    static let playPauseCrossfade: TimeInterval = 0.15

    /// Progress bar update interval (real-time)
    static let progressUpdateInterval: TimeInterval = 0.1

    // Share Action
    /// Share sheet slide-up duration (0.35s spring)
    static let shareSheetAnimation = AppAnimations.gentleSpring

    /// Options stagger delay between items (0.1s)
    static let optionsStaggerDelay: TimeInterval = 0.1
}

// MARK: - View Extensions for Animations
extension View {
    /// Apply button press animation (scale down when tapped)
    /// - Parameter isPressed: Whether the button is currently pressed
    /// - Returns: View with button press animation applied
    func buttonPressAnimation(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AppAnimations.buttonPress, value: isPressed)
    }

    /// Apply card tap animation (subtle scale down)
    /// - Parameter isPressed: Whether the card is currently pressed
    /// - Returns: View with card tap animation applied
    func cardTapAnimation(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? MicroInteractions.cardPressScale : 1.0)
            .animation(AppAnimations.cardTapScale, value: isPressed)
    }

    /// Apply card entrance animation (scale + fade)
    /// - Returns: View with entrance animation applied
    func cardEntranceAnimation() -> some View {
        self
            .transition(AppTransitions.scaleAndFade)
            .animation(AppAnimations.standardSpring, value: UUID())
    }

    /// Apply content fade-in animation with delay
    /// - Parameter isVisible: Whether content should be visible
    /// - Returns: View with fade-in animation applied
    func contentFadeIn(isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(AppAnimations.contentFadeIn, value: isVisible)
    }

    /// Conditional animation that respects Reduce Motion
    /// - Parameters:
    ///   - animation: The animation to apply
    ///   - value: The value to observe for changes
    /// - Returns: View with animation applied (or no animation if Reduce Motion is enabled)
    func conditionalAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        self.modifier(ReduceMotionModifier(animation: animation, value: value))
    }
}

// MARK: - Reduce Motion Support
/// Modifier that respects system Reduce Motion settings
private struct ReduceMotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.animation(animation, value: value)
        }
    }
}
