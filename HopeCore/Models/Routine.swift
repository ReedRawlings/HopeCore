//
//  Routine.swift
//  HopeCore
//
//  Data Model - User Routine Configuration
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Routines are user-defined message delivery schedules
//  - Each routine can have multiple schedules (e.g., morning + evening)
//  - Routines can be enabled/disabled without deleting schedules
//  - Premium users can have unlimited routines, free users limited to 1
//  - Integrates with NotificationManager for scheduled delivery
//

import Foundation
import SwiftData

/// User-defined routine for receiving motivational messages
/// Contains multiple schedules for flexible notification timing
@Model
final class Routine {
    /// Unique identifier
    var id: UUID

    /// User-defined name for the routine (e.g., "Morning Motivation")
    var name: String

    /// Optional description of the routine's purpose
    var routineDescription: String?

    /// Whether the routine is currently active
    var isActive: Bool

    /// Color theme for the routine (hex string)
    var colorHex: String?

    /// Icon name for visual identification
    var iconName: String?

    /// Associated schedules for this routine
    @Relationship(deleteRule: .cascade, inverse: \Schedule.routine)
    var schedules: [Schedule]

    /// Created timestamp
    var createdAt: Date

    /// Last updated timestamp
    var updatedAt: Date

    /// Sort order for display
    var sortOrder: Int

    // MARK: - Computed Properties

    /// Whether routine has any schedules configured
    var hasSchedules: Bool {
        !schedules.isEmpty
    }

    /// Number of active schedules
    var activeScheduleCount: Int {
        schedules.filter { $0.notificationsEnabled }.count
    }

    /// Summary text for display
    var scheduleSummary: String {
        if schedules.isEmpty {
            return "No schedules"
        } else if schedules.count == 1 {
            return schedules[0].summary
        } else {
            return "\(schedules.count) schedules"
        }
    }

    /// All effective days across all schedules
    var allScheduledDays: Set<DayOfWeek> {
        var days = Set<DayOfWeek>()
        for schedule in schedules where schedule.notificationsEnabled {
            days.formUnion(schedule.effectiveDays)
        }
        return days
    }

    /// Next upcoming schedule time (nil if no schedules)
    var nextScheduleTime: Date? {
        guard !schedules.isEmpty else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)

        var nextTimes: [Date] = []

        for schedule in schedules where schedule.notificationsEnabled {
            let effectiveDays = schedule.effectiveDays.map { $0.rawValue }

            for dayRaw in effectiveDays {
                // Calculate days until this weekday
                var daysUntil = dayRaw - currentWeekday
                if daysUntil < 0 {
                    daysUntil += 7
                }

                // Get the schedule time components
                let timeComponents = calendar.dateComponents([.hour, .minute], from: schedule.time)

                // Create date for this weekday with schedule time
                if var targetDate = calendar.date(byAdding: .day, value: daysUntil, to: now) {
                    targetDate = calendar.date(
                        bySettingHour: timeComponents.hour ?? 0,
                        minute: timeComponents.minute ?? 0,
                        second: 0,
                        of: targetDate
                    ) ?? targetDate

                    // If it's today but the time has passed, skip to next week
                    if daysUntil == 0 && targetDate <= now {
                        targetDate = calendar.date(byAdding: .day, value: 7, to: targetDate) ?? targetDate
                    }

                    nextTimes.append(targetDate)
                }
            }
        }

        return nextTimes.min()
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        name: String,
        routineDescription: String? = nil,
        isActive: Bool = true,
        colorHex: String? = nil,
        iconName: String? = "bell.fill",
        schedules: [Schedule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.routineDescription = routineDescription
        self.isActive = isActive
        self.colorHex = colorHex
        self.iconName = iconName
        self.schedules = schedules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
    }

    // MARK: - Methods

    /// Add a new schedule to the routine
    func addSchedule(_ schedule: Schedule) {
        schedule.routine = self
        schedules.append(schedule)
        updatedAt = Date()
    }

    /// Remove a schedule from the routine
    func removeSchedule(_ schedule: Schedule) {
        schedules.removeAll { $0.id == schedule.id }
        updatedAt = Date()
    }

    /// Toggle routine active state
    func toggleActive() {
        isActive.toggle()
        updatedAt = Date()
    }
}

// MARK: - Available Icons
extension Routine {
    /// Available icon options for routines
    static let availableIcons: [String] = [
        "bell.fill",
        "sun.max.fill",
        "moon.fill",
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "flame.fill",
        "leaf.fill",
        "drop.fill",
        "brain.head.profile",
        "figure.walk",
        "cup.and.saucer.fill",
        "book.fill",
        "pencil.and.scribble",
        "sparkles"
    ]

    /// Available color options for routines (hex values)
    static let availableColors: [String] = [
        "#EC4899", // Rose (primary)
        "#10B981", // Emerald (secondary)
        "#F59E0B", // Amber
        "#3B82F6", // Blue
        "#8B5CF6", // Purple
        "#EF4444", // Red
        "#06B6D4", // Cyan
        "#84CC16"  // Lime
    ]
}

// MARK: - Sample Routines
extension Routine {
    /// Sample routines for development and preview
    static let sampleRoutines: [Routine] = {
        // Morning routine with schedule
        let morningSchedule = Schedule(
            time: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .daily,
            label: "Wake up"
        )
        let morningRoutine = Routine(
            name: "Morning Motivation",
            routineDescription: "Start your day with positivity",
            iconName: "sun.max.fill",
            schedules: [morningSchedule],
            sortOrder: 0
        )
        morningSchedule.routine = morningRoutine

        // Work routine with multiple schedules
        let lunchSchedule = Schedule(
            time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .weekdays,
            label: "Lunch break"
        )
        let afternoonSchedule = Schedule(
            time: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .weekdays,
            label: "Afternoon boost"
        )
        let workRoutine = Routine(
            name: "Work Day Boost",
            routineDescription: "Stay motivated during work",
            iconName: "briefcase.fill",
            schedules: [lunchSchedule, afternoonSchedule],
            sortOrder: 1
        )
        lunchSchedule.routine = workRoutine
        afternoonSchedule.routine = workRoutine

        // Evening routine
        let eveningSchedule = Schedule(
            time: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .daily,
            label: "Wind down"
        )
        let eveningRoutine = Routine(
            name: "Evening Reflection",
            routineDescription: "End your day mindfully",
            iconName: "moon.fill",
            schedules: [eveningSchedule],
            sortOrder: 2
        )
        eveningSchedule.routine = eveningRoutine

        return [morningRoutine, workRoutine, eveningRoutine]
    }()
}
