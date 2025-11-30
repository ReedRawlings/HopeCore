//
//  Schedule.swift
//  HopeCore
//
//  Data Model - Routine Schedule Configuration
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Schedules define when routines trigger notifications
//  - Supports specific times and days of week
//  - Multiple schedules can belong to a single routine
//  - Uses SwiftData relationships for persistence
//

import Foundation
import SwiftData

/// Days of the week for scheduling
enum DayOfWeek: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }

    var initial: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

/// Schedule frequency options
enum ScheduleFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "daily"
    case weekdays = "weekdays"
    case weekends = "weekends"
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "Every day"
        case .weekdays: return "Weekdays"
        case .weekends: return "Weekends"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .daily: return "calendar"
        case .weekdays: return "briefcase.fill"
        case .weekends: return "sun.max.fill"
        case .custom: return "calendar.badge.plus"
        }
    }

    /// Default selected days for each frequency
    var defaultDays: [DayOfWeek] {
        switch self {
        case .daily:
            return DayOfWeek.allCases
        case .weekdays:
            return [.monday, .tuesday, .wednesday, .thursday, .friday]
        case .weekends:
            return [.saturday, .sunday]
        case .custom:
            return []
        }
    }
}

/// Schedule configuration for a routine
/// Defines specific times and days when a routine should trigger
@Model
final class Schedule {
    /// Unique identifier
    var id: UUID

    /// Time of day for the schedule (only time component is used)
    var time: Date

    /// Frequency type (daily, weekdays, weekends, custom)
    var frequencyRaw: String

    /// Custom days of week (stored as comma-separated integers)
    /// Only used when frequency is .custom
    var customDaysRaw: String

    /// Whether notifications are enabled for this schedule
    var notificationsEnabled: Bool

    /// Label for the schedule (e.g., "Morning", "Evening")
    var label: String?

    /// Parent routine (inverse relationship)
    var routine: Routine?

    /// Created timestamp
    var createdAt: Date

    // MARK: - Computed Properties

    /// Schedule frequency as enum
    var frequency: ScheduleFrequency {
        get {
            ScheduleFrequency(rawValue: frequencyRaw) ?? .daily
        }
        set {
            frequencyRaw = newValue.rawValue
        }
    }

    /// Custom selected days
    var customDays: [DayOfWeek] {
        get {
            guard !customDaysRaw.isEmpty else { return [] }
            return customDaysRaw
                .split(separator: ",")
                .compactMap { Int($0) }
                .compactMap { DayOfWeek(rawValue: $0) }
        }
        set {
            customDaysRaw = newValue.map { String($0.rawValue) }.joined(separator: ",")
        }
    }

    /// Effective days based on frequency
    var effectiveDays: [DayOfWeek] {
        switch frequency {
        case .custom:
            return customDays
        default:
            return frequency.defaultDays
        }
    }

    /// Formatted time string (e.g., "9:00 AM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    /// Summary of the schedule (e.g., "9:00 AM - Every day")
    var summary: String {
        let daysText: String
        switch frequency {
        case .daily:
            daysText = "Every day"
        case .weekdays:
            daysText = "Weekdays"
        case .weekends:
            daysText = "Weekends"
        case .custom:
            if customDays.isEmpty {
                daysText = "No days selected"
            } else if customDays.count == 7 {
                daysText = "Every day"
            } else {
                daysText = customDays.map { $0.shortName }.joined(separator: ", ")
            }
        }
        return "\(formattedTime) - \(daysText)"
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        time: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        frequency: ScheduleFrequency = .daily,
        customDays: [DayOfWeek] = [],
        notificationsEnabled: Bool = true,
        label: String? = nil,
        routine: Routine? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.time = time
        self.frequencyRaw = frequency.rawValue
        self.customDaysRaw = customDays.map { String($0.rawValue) }.joined(separator: ",")
        self.notificationsEnabled = notificationsEnabled
        self.label = label
        self.routine = routine
        self.createdAt = createdAt
    }
}

// MARK: - Sample Schedules
extension Schedule {
    /// Sample schedules for development and preview
    static let sampleSchedules: [Schedule] = [
        Schedule(
            time: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .daily,
            label: "Morning"
        ),
        Schedule(
            time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .weekdays,
            label: "Lunch"
        ),
        Schedule(
            time: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date(),
            frequency: .daily,
            label: "Evening"
        )
    ]
}
