//
//  HopeCoreWidgetView.swift
//  HopeCoreWidget
//
//  Widget Extension - SwiftUI Views
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Text-only widget display (no images)
//  - Supports accessoryCircular and accessoryRectangular families
//  - Rose border (#EC4899) at 2pt width per design spec
//  - Dark background (#0A0E14) matching app design system
//  - Uses widgetURL for deep linking when tapped
//

import WidgetKit
import SwiftUI

// MARK: - Main Widget View
/// Routes to appropriate view based on widget family
/// Supports both Lock Screen (accessory) and Home Screen (system) widgets
struct HopeCoreWidgetView: View {
    var entry: HopeCoreWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            switch family {
            // Lock Screen widgets
            case .accessoryCircular:
                CircularWidgetView(message: entry.message)
            case .accessoryRectangular:
                RectangularWidgetView(message: entry.message)
            
            // Home Screen widgets
            case .systemSmall:
                HomeScreenSmallWidgetView(message: entry.message)
            case .systemMedium:
                HomeScreenMediumWidgetView(message: entry.message)
            case .systemLarge:
                HomeScreenLargeWidgetView(message: entry.message)
            
            default:
                // Fallback for any other family
                HomeScreenSmallWidgetView(message: entry.message)
            }
        }
        .widgetURL(entry.message?.deepLinkURL)
    }
}

// MARK: - Circular Widget View
/// Compact circular widget for Lock Screen
/// Shows truncated message text with rose border
struct CircularWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        ZStack {
            // Background with rose border
            Circle()
                .fill(WidgetColors.background)
            
            Circle()
                .stroke(WidgetColors.roseBorder, lineWidth: 2)
            
            // Content
            if let message = message {
                Text(message.text)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(6)
            } else {
                // Empty state
                VStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(WidgetColors.roseBorder)
                    Text("HopeCore")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}

// MARK: - Rectangular Widget View
/// Wider rectangular widget for Lock Screen
/// Optimized to show maximum text with minimal padding
/// Shows full message text (up to 4 lines) with rose border
struct RectangularWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(WidgetColors.background)
            
            // Rose border (2pt)
            RoundedRectangle(cornerRadius: 8)
                .stroke(WidgetColors.roseBorder, lineWidth: 2)
            
            // Content
            if let message = message {
                VStack(alignment: .leading, spacing: 0) {
                    // Message text - maximized for readability
                    // Removed category badge to save space for more text
                    Text(message.text)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(4) // Increased from 2 to 4 lines
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.85) // Slightly more aggressive scaling
                        .fixedSize(horizontal: false, vertical: true) // Allow natural height
                }
                .padding(.horizontal, 12) // Slightly reduced horizontal padding
                .padding(.vertical, 10) // Optimized vertical padding
                .frame(maxWidth: .infinity, alignment: .leading) // Use full width
            } else {
                // Empty state
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(WidgetColors.roseBorder)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HopeCore")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Open app to get started")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Widget Colors
/// Design system colors for widget
/// AGENT NOTE: These match the main app's Colors.swift but are duplicated here
/// because widget extensions cannot import main app code directly
struct WidgetColors {
    /// Rose/magenta accent color (#EC4899)
    static let roseBorder = Color(hex: "#EC4899")
    
    /// Dark background color (#0A0E14)
    static let background = Color(hex: "#0A0E14")
    
    /// Secondary background (#0F1419)
    static let backgroundSecondary = Color(hex: "#0F1419")
}

// MARK: - Color Extension for Hex Support
/// Allows creating colors from hex strings
/// Duplicated from main app since widget cannot import app code
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Home Screen Widget Views

/// Small Home Screen widget (2x2 grid space)
/// Shows message text with category badge
struct HomeScreenSmallWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(WidgetColors.background)
            
            // Rose border (2pt)
            RoundedRectangle(cornerRadius: 16)
                .stroke(WidgetColors.roseBorder, lineWidth: 2)
            
            // Content
            if let message = message {
                VStack(alignment: .leading, spacing: 6) {
                    // Category badge
                    Text(message.categoryName.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(WidgetColors.roseBorder)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(WidgetColors.roseBorder.opacity(0.15))
                        )
                    
                    // Message text
                    Text(message.text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                }
                .padding(12)
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(WidgetColors.roseBorder)
                    
                    Text("HopeCore")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Open app to get started")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}

/// Medium Home Screen widget (4x2 grid space)
/// Shows message text with more space for longer quotes
struct HomeScreenMediumWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(WidgetColors.background)
            
            // Rose border (2pt)
            RoundedRectangle(cornerRadius: 16)
                .stroke(WidgetColors.roseBorder, lineWidth: 2)
            
            // Content
            if let message = message {
                VStack(alignment: .leading, spacing: 8) {
                    // Header with category
                    HStack {
                        Text(message.categoryName.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(WidgetColors.roseBorder)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(WidgetColors.roseBorder.opacity(0.15))
                            )
                        
                        Spacer()
                    }
                    
                    // Message text (more lines for medium size)
                    Text(message.text)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(6)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.85)
                    
                    Spacer()
                }
                .padding(16)
            } else {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(WidgetColors.roseBorder)
                    
                    Text("HopeCore")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Open app to get started")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
}

/// Large Home Screen widget (4x4 grid space)
/// Shows full message with category and app branding
struct HomeScreenLargeWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(WidgetColors.background)
            
            // Rose border (2pt)
            RoundedRectangle(cornerRadius: 16)
                .stroke(WidgetColors.roseBorder, lineWidth: 2)
            
            // Content
            if let message = message {
                VStack(alignment: .leading, spacing: 12) {
                    // Header with category and app name
                    HStack {
                        Text(message.categoryName.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WidgetColors.roseBorder)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(WidgetColors.roseBorder.opacity(0.15))
                            )
                        
                        Spacer()
                        
                        Text("HopeCore")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    // Message text (full quote for large size)
                    Text(message.text)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Footer with heart icon
                    HStack {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(WidgetColors.roseBorder.opacity(0.6))
                    }
                }
                .padding(20)
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(WidgetColors.roseBorder)
                    
                    Text("HopeCore")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Open app to get started")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text("Your daily inspiration awaits")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Rectangular - With Message", as: .accessoryRectangular) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "You'll never feel ready. Do it anyway.",
            categoryName: "Agency"
        )
    )
}

#Preview("Circular - With Message", as: .accessoryCircular) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "Start now.",
            categoryName: "Agency"
        )
    )
}

#Preview("Home Screen Small", as: .systemSmall) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "A ship in the harbor is safe, but that is not what ships are built for.",
            categoryName: "Possibility"
        )
    )
}

#Preview("Home Screen Medium", as: .systemMedium) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "You'll never feel ready. Do it anyway. The perfect moment doesn't exist.",
            categoryName: "Agency"
        )
    )
}

#Preview("Home Screen Large", as: .systemLarge) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle.",
            categoryName: "Purpose"
        )
    )
}

