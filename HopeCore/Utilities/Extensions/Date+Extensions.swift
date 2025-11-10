//
//  Date+Extensions.swift
//  HopeCore
//
//  Utilities - Date Extensions
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Date formatting helpers
//  - Relative time descriptions
//  - Notification time calculations
//  - Widget update scheduling
//

import Foundation

extension Date {

    // MARK: - Formatting

    /// Format date as time string (e.g., "9:30 AM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }

    /// Format date as short date string (e.g., "Nov 10")
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Format date as full date string (e.g., "November 10, 2025")
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }

    /// Format date with time (e.g., "Nov 10, 9:30 AM")
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: self)
    }

    // MARK: - Relative Time

    /// Get relative time string (e.g., "2 hours ago", "Just now")
    var relativeTimeString: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        // Future dates
        if interval < 0 {
            return "In the future"
        }

        // Just now (< 1 minute)
        if interval < 60 {
            return "Just now"
        }

        // Minutes ago
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        }

        // Hours ago
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        }

        // Days ago
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) \(days == 1 ? "day" : "days") ago"
        }

        // Weeks ago
        if interval < 2592000 {
            let weeks = Int(interval / 604800)
            return "\(weeks) \(weeks == 1 ? "week" : "weeks") ago"
        }

        // Months ago
        if interval < 31536000 {
            let months = Int(interval / 2592000)
            return "\(months) \(months == 1 ? "month" : "months") ago"
        }

        // Years ago
        let years = Int(interval / 31536000)
        return "\(years) \(years == 1 ? "year" : "years") ago"
    }

    /// Short relative time (e.g., "2h ago", "3d ago")
    var shortRelativeTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        if interval < 60 {
            return "Now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else if interval < 604800 {
            return "\(Int(interval / 86400))d ago"
        } else {
            return shortDateString
        }
    }

    // MARK: - Date Comparisons

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Check if date is in current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if date is in current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Check if date is in current year
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    // MARK: - Date Manipulation

    /// Add days to date
    /// - Parameter days: Number of days to add
    /// - Returns: New date
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add hours to date
    /// - Parameter hours: Number of hours to add
    /// - Returns: New date
    func addingHours(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    /// Add minutes to date
    /// - Parameter minutes: Number of minutes to add
    /// - Returns: New date
    func addingMinutes(_ minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    /// Start of day (midnight)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// End of day (23:59:59)
    var endOfDay: Date {
        let start = startOfDay
        return Calendar.current.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-1) ?? self
    }

    // MARK: - Components

    /// Hour component (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    /// Minute component (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    /// Day component (1-31)
    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    /// Month component (1-12)
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    /// Year component
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Weekday component (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    // MARK: - Notification Helpers

    /// Create date from hour and minute (today)
    /// - Parameters:
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    /// - Returns: Date with specified time today
    static func timeToday(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }

    /// Check if time falls within quiet hours
    /// - Parameters:
    ///   - quietStart: Quiet hours start time
    ///   - quietEnd: Quiet hours end time
    /// - Returns: Whether time is in quiet hours
    func isInQuietHours(start quietStart: Date, end quietEnd: Date) -> Bool {
        let calendar = Calendar.current

        let currentHour = calendar.component(.hour, from: self)
        let currentMinute = calendar.component(.minute, from: self)
        let currentTime = currentHour * 60 + currentMinute

        let startHour = calendar.component(.hour, from: quietStart)
        let startMinute = calendar.component(.minute, from: quietStart)
        let startTime = startHour * 60 + startMinute

        let endHour = calendar.component(.hour, from: quietEnd)
        let endMinute = calendar.component(.minute, from: quietEnd)
        let endTime = endHour * 60 + endMinute

        // Handle overnight quiet hours
        if startTime > endTime {
            return currentTime >= startTime || currentTime <= endTime
        } else {
            return currentTime >= startTime && currentTime <= endTime
        }
    }
}

// MARK: - TimeInterval Extension
extension TimeInterval {
    /// Format time interval as duration string (e.g., "12:34")
    var durationString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Format time interval as hours and minutes (e.g., "2h 15m")
    var hoursMinutesString: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
