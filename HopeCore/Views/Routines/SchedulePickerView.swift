//
//  SchedulePickerView.swift
//  HopeCore
//
//  View - Schedule Configuration Component
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Reusable component for configuring a single schedule
//  - Time picker for selecting notification time
//  - Frequency selector (daily, weekdays, weekends, custom)
//  - Custom day picker when frequency is custom
//  - Used within AddRoutineView for schedule configuration
//

import SwiftUI

/// View for configuring a single schedule
struct SchedulePickerView: View {
    // MARK: - Bindings

    @Binding var time: Date
    @Binding var frequency: ScheduleFrequency
    @Binding var customDays: [DayOfWeek]
    @Binding var notificationsEnabled: Bool
    @Binding var label: String

    // MARK: - State

    @State private var showTimePicker = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Time selection
            timeSection

            // Frequency selection
            frequencySection

            // Custom days (when frequency is custom)
            if frequency == .custom {
                customDaysSection
            }

            // Notifications toggle
            notificationSection
        }
    }

    // MARK: - Time Section

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Time")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)

            DatePicker(
                "",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxHeight: 120)
            .background(BackgroundColors.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
        }
    }

    // MARK: - Frequency Section

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Repeat")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)

            HStack(spacing: Spacing.xs) {
                ForEach(ScheduleFrequency.allCases) { freq in
                    frequencyButton(freq)
                }
            }
        }
    }

    private func frequencyButton(_ freq: ScheduleFrequency) -> some View {
        Button(action: {
            HapticFeedback.selection()
            frequency = freq
            // Reset custom days when changing to non-custom
            if freq != .custom {
                customDays = []
            }
        }) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: freq.iconName)
                    .font(.system(size: 16))
                Text(freq == .custom ? "Custom" : freq.displayName.components(separatedBy: " ").first ?? freq.displayName)
                    .font(AppFonts.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .fill(frequency == freq ? AccentColors.primary.opacity(0.2) : BackgroundColors.tertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .stroke(frequency == freq ? AccentColors.primary : Color.clear, lineWidth: 1.5)
            )
            .foregroundColor(frequency == freq ? AccentColors.primary : TextColors.secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom Days Section

    private var customDaysSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Days")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)

            HStack(spacing: Spacing.xs) {
                ForEach(DayOfWeek.allCases) { day in
                    dayButton(day)
                }
            }
        }
    }

    private func dayButton(_ day: DayOfWeek) -> some View {
        let isSelected = customDays.contains(day)

        return Button(action: {
            HapticFeedback.selection()
            if isSelected {
                customDays.removeAll { $0 == day }
            } else {
                customDays.append(day)
                customDays.sort { $0.rawValue < $1.rawValue }
            }
        }) {
            Text(day.initial)
                .font(AppFonts.smallBody)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? AccentColors.primary : BackgroundColors.tertiary)
                )
                .foregroundColor(isSelected ? TextColors.inverse : TextColors.secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Toggle(isOn: $notificationsEnabled) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash")
                    .foregroundColor(notificationsEnabled ? AccentColors.primary : TextColors.tertiary)
                Text("Notifications")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)
            }
        }
        .tint(AccentColors.primary)
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Compact Schedule Row

/// Compact display of a schedule for list views
struct ScheduleRow: View {
    let schedule: Schedule
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Time display
            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.formattedTime)
                    .font(AppFonts.subtitle)
                    .foregroundColor(TextColors.primary)

                Text(schedule.frequency.displayName)
                    .font(AppFonts.caption)
                    .foregroundColor(TextColors.secondary)
            }

            Spacer()

            // Days indicators
            if schedule.frequency == .custom && !schedule.customDays.isEmpty {
                HStack(spacing: 2) {
                    ForEach(schedule.customDays) { day in
                        Text(day.initial)
                            .font(AppFonts.caption)
                            .foregroundColor(AccentColors.primary)
                    }
                }
            }

            // Notification indicator
            Image(systemName: schedule.notificationsEnabled ? "bell.fill" : "bell.slash")
                .font(.system(size: 14))
                .foregroundColor(schedule.notificationsEnabled ? AccentColors.primary : TextColors.tertiary)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(TextColors.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.sm)
        .background(BackgroundColors.tertiary)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
    }
}

// MARK: - Add Schedule Button

/// Button to add a new schedule
struct AddScheduleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.buttonPress()
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Add Schedule")
                    .font(AppFonts.regularBody)
            }
            .foregroundColor(AccentColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                    .stroke(AccentColors.primary.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Schedule Picker") {
    struct PreviewWrapper: View {
        @State private var time = Date()
        @State private var frequency: ScheduleFrequency = .daily
        @State private var customDays: [DayOfWeek] = []
        @State private var notificationsEnabled = true
        @State private var label = ""

        var body: some View {
            ZStack {
                BackgroundColors.primary.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        SchedulePickerView(
                            time: $time,
                            frequency: $frequency,
                            customDays: $customDays,
                            notificationsEnabled: $notificationsEnabled,
                            label: $label
                        )
                    }
                    .padding()
                }
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Schedule Row") {
    ZStack {
        BackgroundColors.primary.ignoresSafeArea()
        VStack {
            ScheduleRow(schedule: Schedule.sampleSchedules[0]) { }
            ScheduleRow(schedule: Schedule.sampleSchedules[1]) { }
        }
        .padding()
    }
}
