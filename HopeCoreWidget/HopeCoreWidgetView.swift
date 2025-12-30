//
//  HopeCoreWidgetView.swift
//  HopeCoreWidget
//
//  Simple widget: Black background, white text
//
//  AGENT NOTES:
//  - Font sizes are optimized for each widget size
//  - All widgets use system fonts for reliability
//  - minimumScaleFactor allows text to shrink for long quotes
//  - Lock screen widgets are more constrained than home screen
//

import WidgetKit
import SwiftUI

// MARK: - Widget Font Sizes
/// Optimized font sizes for each widget family
/// These match the WidgetFonts struct in the main app
private enum WidgetFontSize {
    // Lock Screen
    static let circular: CGFloat = 11
    static let circularMinScale: CGFloat = 0.6
    static let circularLineLimit: Int = 4

    static let rectangular: CGFloat = 13
    static let rectangularMinScale: CGFloat = 0.75
    static let rectangularLineLimit: Int = 3

    // Home Screen
    static let small: CGFloat = 15
    static let smallMinScale: CGFloat = 0.65
    static let smallLineLimit: Int = 6

    static let medium: CGFloat = 17
    static let mediumMinScale: CGFloat = 0.7
    static let mediumLineLimit: Int = 5

    static let large: CGFloat = 20
    static let largeMinScale: CGFloat = 0.75
    static let largeLineLimit: Int = 10
}

// MARK: - Main Widget View

struct HopeCoreWidgetView: View {
    var entry: HopeCoreWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                CircularWidgetView(message: entry.message)
            case .accessoryRectangular:
                RectangularWidgetView(message: entry.message)
            case .systemSmall:
                HomeScreenSmallWidgetView(message: entry.message)
            case .systemMedium:
                HomeScreenMediumWidgetView(message: entry.message)
            case .systemLarge:
                HomeScreenLargeWidgetView(message: entry.message)
            default:
                HomeScreenSmallWidgetView(message: entry.message)
            }
        }
        .widgetURL(entry.message?.deepLinkURL)
    }
}

// MARK: - Lock Screen Widgets

struct CircularWidgetView: View {
    let message: WidgetMessage?

    var body: some View {
        if let message = message {
            Text(message.text)
                .font(.system(size: WidgetFontSize.circular, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(WidgetFontSize.circularLineLimit)
                .minimumScaleFactor(WidgetFontSize.circularMinScale)
        } else {
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }
}

struct RectangularWidgetView: View {
    let message: WidgetMessage?

    var body: some View {
        if let message = message {
            Text(message.text)
                .font(.system(size: WidgetFontSize.rectangular, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(WidgetFontSize.rectangularLineLimit)
                .minimumScaleFactor(WidgetFontSize.rectangularMinScale)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            Text("HopeCore")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Home Screen Widgets

struct HomeScreenSmallWidgetView: View {
    let message: WidgetMessage?
    private let backgroundImage = WidgetDataStore.getBackgroundImage()

    var body: some View {
        ZStack {
            // Background image
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)

            // Dark overlay for text readability
            Color.black.opacity(0.4)

            // Content
            if let message = message {
                Text(message.text)
                    .font(.system(size: WidgetFontSize.small, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .lineLimit(WidgetFontSize.smallLineLimit)
                    .minimumScaleFactor(WidgetFontSize.smallMinScale)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(12)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.pink)
                    Text("HopeCore")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct HomeScreenMediumWidgetView: View {
    let message: WidgetMessage?
    private let backgroundImage = WidgetDataStore.getBackgroundImage()

    var body: some View {
        ZStack {
            // Background image
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)

            // Dark overlay for text readability
            Color.black.opacity(0.4)

            // Content
            if let message = message {
                Text(message.text)
                    .font(.system(size: WidgetFontSize.medium, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .lineLimit(WidgetFontSize.mediumLineLimit)
                    .minimumScaleFactor(WidgetFontSize.mediumMinScale)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .padding(16)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.pink)
                    Text("HopeCore")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct HomeScreenLargeWidgetView: View {
    let message: WidgetMessage?
    private let backgroundImage = WidgetDataStore.getBackgroundImage()

    var body: some View {
        ZStack {
            // Background image
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)

            // Dark overlay for text readability
            Color.black.opacity(0.35)

            // Content
            if let message = message {
                Text(message.text)
                    .font(.system(size: WidgetFontSize.large, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(WidgetFontSize.largeLineLimit)
                    .minimumScaleFactor(WidgetFontSize.largeMinScale)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                    .padding(20)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.pink)
                    Text("HopeCore")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Preview Sample Messages

private enum PreviewMessages {
    static let short = "Fear is an invitation to evolve"
    static let medium = "The only impossible journey is the one you never begin."
    static let long = "You need to give yourself something to work toward and an expectation for your life. You must do these things in earnest. You can't half ass your life's work."
    static let veryLong = "The difference between a successful person and an unsuccessful one is their fixation on failures rather than looking to their failures as moments in time. You can learn from each moment, but if you embody the failure you become failure yourself."
}

// MARK: - Previews

#Preview("Small - Short", as: .systemSmall) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.short,
            categoryName: "Agency"
        )
    )
}

#Preview("Small - Long", as: .systemSmall) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.long,
            categoryName: "Agency"
        )
    )
}

#Preview("Medium - Short", as: .systemMedium) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.short,
            categoryName: "Agency"
        )
    )
}

#Preview("Medium - Long", as: .systemMedium) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.veryLong,
            categoryName: "Agency"
        )
    )
}

#Preview("Large - Short", as: .systemLarge) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.short,
            categoryName: "Agency"
        )
    )
}

#Preview("Large - Long", as: .systemLarge) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.veryLong,
            categoryName: "Agency"
        )
    )
}

#Preview("Rectangular - Long", as: .accessoryRectangular) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: PreviewMessages.long,
            categoryName: "Agency"
        )
    )
}
