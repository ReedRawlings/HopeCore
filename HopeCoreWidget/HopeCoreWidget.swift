//
//  HopeCoreWidget.swift
//  HopeCoreWidget
//
//  Created by Reed Rawlings on 11/30/25.
//
//  Widget Extension - Main Widget Configuration
//  AGENT NOTES:
//  - Uses StaticConfiguration (no user configuration needed)
//  - Supports Lock Screen widgets: accessoryCircular and accessoryRectangular
//  - Timeline updates once daily at 6 AM for free users
//  - Widget displays text-only quotes (no images)
//

import WidgetKit
import SwiftUI

// MARK: - Widget Configuration
/// HopeCore widget showing daily inspirational messages
/// Available for both Lock Screen and Home Screen
/// Text-only display showing only the quote, maximized for visual space
/// Updates according to notification schedule
/// Tapping opens the app to the specific message
struct HopeCoreWidget: Widget {
    /// Unique identifier for this widget
    /// Used when reloading timelines: WidgetCenter.shared.reloadTimelines(ofKind: kind)
    let kind: String = "HopeCoreWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: HopeCoreWidgetProvider()
        ) { entry in
            HopeCoreWidgetView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("Daily Message")
        .description("Shows your daily HopeCore inspirational message. Updates automatically based on your notification schedule.")
        .supportedFamilies([
            // Lock Screen widgets
            .accessoryCircular,
            .accessoryRectangular,
            // Home Screen widgets
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

// MARK: - Timeline Provider
/// Provides timeline entries for the widget
/// Determines when the widget updates and what content to display
struct HopeCoreWidgetProvider: TimelineProvider {
    typealias Entry = HopeCoreWidgetEntry
    
    /// Placeholder shown while widget is loading
    func placeholder(in context: Context) -> Entry {
        HopeCoreWidgetEntry(
            date: Date(),
            message: WidgetMessage(
                id: UUID(),
                text: "Your daily inspiration awaits...",
                categoryName: "HopeCore"
            )
        )
    }
    
    /// Snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let message = WidgetDataStore.getTodaysMessage()
        let entry = HopeCoreWidgetEntry(
            date: Date(),
            message: message ?? WidgetMessage(
                id: UUID(),
                text: "A ship in the harbor is safe, but that is not what ships are built for.",
                categoryName: "Possibility"
            )
        )
        completion(entry)
    }
    
    /// Timeline for actual widget display
    /// Creates entries for each scheduled notification time
    /// Widget will automatically update at each time to show the corresponding message
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        
        // Get scheduled messages from WidgetDataStore
        let scheduledMessages = WidgetDataStore.getScheduledMessages()
        
        var entries: [HopeCoreWidgetEntry] = []
        
        if !scheduledMessages.isEmpty {
            // Create an entry for each scheduled notification time
            for (time, message) in scheduledMessages {
                // Only include entries for today and future times
                // Normalize time to today's date
                let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                
                var entryDateComponents = todayComponents
                entryDateComponents.hour = timeComponents.hour
                entryDateComponents.minute = timeComponents.minute
                entryDateComponents.second = 0
                
                if let entryDate = calendar.date(from: entryDateComponents) {
                    // If this time has already passed today, schedule for tomorrow
                    let finalDate = entryDate <= now ? calendar.date(byAdding: .day, value: 1, to: entryDate) ?? entryDate : entryDate
                    
                    let entry = HopeCoreWidgetEntry(date: finalDate, message: message)
                    entries.append(entry)
                }
            }
            
            // Sort entries by date
            entries.sort { $0.date < $1.date }
            
            // Add a current entry showing the message for right now
            let currentMessage = WidgetDataStore.getMessageForTime(now) ?? WidgetDataStore.getTodaysMessage()
            let currentEntry = HopeCoreWidgetEntry(date: now, message: currentMessage)
            entries.insert(currentEntry, at: 0)
        } else {
            // Fallback: No schedule, use single daily message
            let message = WidgetDataStore.getTodaysMessage()
            let entry = HopeCoreWidgetEntry(date: now, message: message)
            entries.append(entry)
        }
        
        // Calculate next update time
        // If we have scheduled entries, use the next one
        // Otherwise, default to 6 AM next day
        let nextUpdate: Date
        if let nextEntry = entries.first(where: { $0.date > now }) {
            nextUpdate = nextEntry.date
        } else {
            nextUpdate = calculateNextUpdate()
        }
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    /// Calculate next widget update time (fallback)
    /// - Returns: Date for next scheduled update (6 AM next day)
    private func calculateNextUpdate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Default to 6 AM next day
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        components.second = 0
        
        var nextUpdate = calendar.date(from: components) ?? now
        
        // If 6 AM today has passed, schedule for tomorrow
        if nextUpdate <= now {
            nextUpdate = calendar.date(byAdding: .day, value: 1, to: nextUpdate) ?? now
        }
        
        return nextUpdate
    }
}

// MARK: - Previews
#Preview(as: .accessoryRectangular) {
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
    HopeCoreWidgetEntry(date: Date(), message: nil)
}

#Preview(as: .accessoryCircular) {
    HopeCoreWidget()
} timeline: {
    HopeCoreWidgetEntry(
        date: Date(),
        message: WidgetMessage(
            id: UUID(),
            text: "Start before you're ready.",
            categoryName: "Agency"
        )
    )
}
