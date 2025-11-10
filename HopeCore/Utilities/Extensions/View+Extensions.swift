//
//  View+Extensions.swift
//  HopeCore
//
//  Utilities - SwiftUI View Extensions
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Convenience extensions for common view modifications
//  - Implements design system styling
//  - Provides reusable modifiers for consistent UI
//  - Reduces code duplication across views
//

import SwiftUI

// MARK: - Card Styling
extension View {
    /// Apply standard message card styling
    /// Glass background + corner radius + padding
    func messageCardStyle() -> some View {
        self
            .padding(ComponentSpacing.messageCardPadding)
            .background(MaterialStyles.ultraThin)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    /// Apply solid card styling for text-heavy content
    func solidMessageCardStyle() -> some View {
        self
            .padding(ComponentSpacing.messageCardPadding)
            .background(BackgroundColors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    /// Apply audio card styling
    func audioCardStyle() -> some View {
        self
            .padding(ComponentSpacing.audioComponentPadding)
            .background(MaterialStyles.ultraThin)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
    }
}

// MARK: - Button Styling
extension View {
    /// Primary button style (rose/magenta accent)
    func primaryButtonStyle() -> some View {
        self
            .font(AppFonts.buttonPrimary)
            .foregroundColor(TextColors.primary)
            .frame(height: ComponentSpacing.primaryButtonHeight)
            .frame(maxWidth: .infinity)
            .background(AccentColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
    }

    /// Secondary button style (transparent with border)
    func secondaryButtonStyle() -> some View {
        self
            .font(AppFonts.buttonSecondary)
            .foregroundColor(AccentColors.primary)
            .frame(height: ComponentSpacing.minTapTarget)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .stroke(AccentColors.primary, lineWidth: 2)
            )
    }

    /// Icon button style (circular)
    func iconButtonStyle(size: CGFloat = 44) -> some View {
        self
            .frame(width: size, height: size)
            .background(MaterialStyles.ultraThin)
            .clipShape(Circle())
    }
}

// MARK: - Conditional Modifiers
extension View {
    /// Apply modifier conditionally
    /// - Parameters:
    ///   - condition: Whether to apply the modifier
    ///   - transform: Modifier to apply
    /// - Returns: Modified view
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply one of two modifiers based on condition
    /// - Parameters:
    ///   - condition: Condition to check
    ///   - ifTransform: Modifier if condition is true
    ///   - elseTransform: Modifier if condition is false
    /// - Returns: Modified view
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - Saved State Styling
extension View {
    /// Apply saved state styling (rose border + filled heart)
    /// - Parameter isSaved: Whether item is saved
    /// - Returns: View with saved styling
    func savedStateStyle(isSaved: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                .stroke(
                    isSaved ? AccentColors.primary : Color.clear,
                    lineWidth: ComponentSpacing.cardBorderWidth
                )
        )
    }
}

// MARK: - Loading State
extension View {
    /// Add loading overlay
    /// - Parameter isLoading: Whether to show loading state
    /// - Returns: View with loading overlay
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                        ProgressView()
                            .tint(AccentColors.primary)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
                }
            }
        )
    }
}

// MARK: - Shake Animation
extension View {
    /// Shake animation for errors/validation
    /// - Parameter shake: Binding to trigger shake
    /// - Returns: View with shake animation
    func shake(_ shake: Binding<Bool>) -> some View {
        self.modifier(ShakeEffect(shake: shake))
    }
}

struct ShakeEffect: GeometryEffect {
    var shake: Bool
    var animatableData: CGFloat

    init(shake: Binding<Bool>) {
        self.shake = shake.wrappedValue
        self.animatableData = shake.wrappedValue ? 1 : 0
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = 10 * sin(animatableData * .pi * 3)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

// MARK: - Shimmer Effect
extension View {
    /// Add shimmer loading effect
    /// - Parameter isActive: Whether shimmer is active
    /// - Returns: View with shimmer effect
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(isActive ? 0.3 : 0),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                if isActive {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 300
                    }
                }
            }
    }
}

// MARK: - Keyboard Handling
extension View {
    /// Dismiss keyboard on tap
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Safe Area Insets
extension View {
    /// Ignore specific safe area edges
    /// - Parameter edges: Edges to ignore
    /// - Returns: View ignoring safe area on specified edges
    func ignoreSafeArea(_ edges: Edge.Set) -> some View {
        self.edgesIgnoringSafeArea(edges)
    }
}

// MARK: - Frame Helpers
extension View {
    /// Set frame to fill available space
    func fillWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    func fillHeight(alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

    func fillSpace(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Hidden Modifier
extension View {
    /// Hide view based on condition
    /// - Parameter isHidden: Whether view should be hidden
    /// - Returns: View with opacity 0 if hidden
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
