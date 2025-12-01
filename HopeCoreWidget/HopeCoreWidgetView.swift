//
//  HopeCoreWidgetView.swift
//  HopeCoreWidget
//
//  Simple widget: Black background, white text
//

import WidgetKit
import SwiftUI

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
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
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
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: .leading)
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
    
    var body: some View {
        if let message = message {
            Text(message.text)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.6)
                .padding(16)
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

struct HomeScreenMediumWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        if let message = message {
            Text(message.text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.6)
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

struct HomeScreenLargeWidgetView: View {
    let message: WidgetMessage?
    
    var body: some View {
        if let message = message {
            Text(message.text)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.6)
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

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "The only impossible journey is the one you never begin.",
            categoryName: "Agency"
        )
    )
}

#Preview("Medium", as: .systemMedium) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "The only impossible journey is the one you never begin.",
            categoryName: "Agency"
        )
    )
}

#Preview("Large", as: .systemLarge) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "The only impossible journey is the one you never begin.",
            categoryName: "Agency"
        )
    )
}
