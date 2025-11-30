//
//  AddRoutineView.swift
//  HopeCore
//
//  View - Create/Edit Routine
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Form for creating a new routine or editing existing one
//  - Includes routine name, description, and schedule configuration
//  - Schedule section allows adding multiple schedules per routine
//  - Validates input before allowing save
//  - Integrates with SwiftData for persistence
//

import SwiftUI
import SwiftData

struct AddRoutineView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    /// Existing routine to edit (nil for new routine)
    var existingRoutine: Routine?

    /// Callback when routine is saved
    var onSave: ((Routine) -> Void)?

    // MARK: - State

    @State private var routineName: String = ""
    @State private var routineDescription: String = ""
    @State private var selectedIcon: String = "bell.fill"
    @State private var selectedColor: String = "#EC4899"
    @State private var isActive: Bool = true

    // Schedule editing
    @State private var schedules: [ScheduleData] = []
    @State private var showAddSchedule = false
    @State private var editingScheduleIndex: Int?

    // Validation
    @State private var showValidationError = false
    @State private var validationMessage = ""

    // MARK: - Computed

    private var isEditing: Bool {
        existingRoutine != nil
    }

    private var canSave: Bool {
        !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColors.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Routine Details Section
                        routineDetailsSection

                        // Icon & Color Section
                        iconColorSection

                        // Schedules Section
                        schedulesSection

                        // Spacer for bottom padding
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, ScreenLayout.horizontalMargin)
                    .padding(.top, Spacing.lg)
                }

                // Save Button at bottom
                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.buttonPress()
                        dismiss()
                    }
                    .foregroundColor(TextColors.secondary)
                }
            }
            .sheet(isPresented: $showAddSchedule) {
                AddScheduleSheet(
                    onSave: { scheduleData in
                        schedules.append(scheduleData)
                        showAddSchedule = false
                    }
                )
            }
            .sheet(item: $editingScheduleIndex) { index in
                if index < schedules.count {
                    EditScheduleSheet(
                        scheduleData: schedules[index],
                        onSave: { updatedData in
                            schedules[index] = updatedData
                            editingScheduleIndex = nil
                        },
                        onDelete: {
                            schedules.remove(at: index)
                            editingScheduleIndex = nil
                        }
                    )
                }
            }
            .alert("Invalid Routine", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                loadExistingRoutine()
            }
        }
    }

    // MARK: - Routine Details Section

    private var routineDetailsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("ROUTINE DETAILS")
                .font(AppFonts.caption)
                .foregroundColor(TextColors.tertiary)
                .tracking(1)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Routine Name")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)

                TextField("e.g., Upper Body Day", text: $routineName)
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)
                    .padding(Spacing.md)
                    .background(BackgroundColors.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Description (optional)")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)

                TextField("Add a description...", text: $routineDescription, axis: .vertical)
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.primary)
                    .lineLimit(3...6)
                    .padding(Spacing.md)
                    .background(BackgroundColors.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }
        }
        .padding(Spacing.md)
        .background(BackgroundColors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    // MARK: - Icon & Color Section

    private var iconColorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("APPEARANCE")
                .font(AppFonts.caption)
                .foregroundColor(TextColors.tertiary)
                .tracking(1)

            // Icon selection
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Icon")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 5), spacing: Spacing.xs) {
                    ForEach(Routine.availableIcons, id: \.self) { icon in
                        iconButton(icon)
                    }
                }
            }

            // Color selection
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Color")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.secondary)

                HStack(spacing: Spacing.sm) {
                    ForEach(Routine.availableColors, id: \.self) { color in
                        colorButton(color)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(BackgroundColors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    private func iconButton(_ icon: String) -> some View {
        let isSelected = selectedIcon == icon
        return Button(action: {
            HapticFeedback.selection()
            selectedIcon = icon
        }) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: selectedColor).opacity(0.2) : BackgroundColors.tertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                )
                .foregroundColor(isSelected ? Color(hex: selectedColor) : TextColors.secondary)
        }
        .buttonStyle(.plain)
    }

    private func colorButton(_ colorHex: String) -> some View {
        let isSelected = selectedColor == colorHex
        return Button(action: {
            HapticFeedback.selection()
            selectedColor = colorHex
        }) {
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: colorHex), lineWidth: isSelected ? 1 : 0)
                        .padding(2)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Schedules Section

    private var schedulesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("SCHEDULES")
                    .font(AppFonts.caption)
                    .foregroundColor(TextColors.tertiary)
                    .tracking(1)

                Spacer()

                if !schedules.isEmpty {
                    Text("\(schedules.count) schedule\(schedules.count == 1 ? "" : "s")")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.secondary)
                }
            }

            if schedules.isEmpty {
                emptySchedulesView
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(schedules.enumerated()), id: \.offset) { index, schedule in
                        scheduleRowView(schedule: schedule, index: index)
                    }
                }
            }

            AddScheduleButton {
                showAddSchedule = true
            }
        }
        .padding(Spacing.md)
        .background(BackgroundColors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
    }

    private var emptySchedulesView: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 32))
                .foregroundColor(TextColors.tertiary)

            Text("No schedules yet")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)

            Text("Add schedules to receive notifications at specific times")
                .font(AppFonts.caption)
                .foregroundColor(TextColors.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }

    private func scheduleRowView(schedule: ScheduleData, index: Int) -> some View {
        Button(action: {
            HapticFeedback.buttonPress()
            editingScheduleIndex = index
        }) {
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

                // Days indicators for custom
                if schedule.frequency == .custom && !schedule.customDays.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(schedule.customDays) { day in
                            Text(day.initial)
                                .font(AppFonts.caption)
                                .foregroundColor(Color(hex: selectedColor))
                        }
                    }
                }

                // Notification indicator
                Image(systemName: schedule.notificationsEnabled ? "bell.fill" : "bell.slash")
                    .font(.system(size: 14))
                    .foregroundColor(schedule.notificationsEnabled ? Color(hex: selectedColor) : TextColors.tertiary)

                // Edit indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(TextColors.tertiary)
            }
            .padding(Spacing.sm)
            .background(BackgroundColors.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: saveRoutine) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                Text(isEditing ? "Save Changes" : "Create Routine")
                    .font(AppFonts.buttonPrimary)
            }
            .foregroundColor(canSave ? TextColors.inverse : TextColors.tertiary)
            .frame(maxWidth: .infinity)
            .frame(height: ComponentSpacing.primaryButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                    .fill(canSave ? AccentColors.primary : BackgroundColors.tertiary)
            )
        }
        .disabled(!canSave)
        .padding(.horizontal, ScreenLayout.horizontalMargin)
        .padding(.bottom, ScreenLayout.bottomMargin)
        .background(
            LinearGradient(
                colors: [BackgroundColors.primary.opacity(0), BackgroundColors.primary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false)
        )
    }

    // MARK: - Actions

    private func loadExistingRoutine() {
        guard let routine = existingRoutine else { return }

        routineName = routine.name
        routineDescription = routine.routineDescription ?? ""
        selectedIcon = routine.iconName ?? "bell.fill"
        selectedColor = routine.colorHex ?? "#EC4899"
        isActive = routine.isActive

        // Convert existing schedules to ScheduleData
        schedules = routine.schedules.map { schedule in
            ScheduleData(
                time: schedule.time,
                frequency: schedule.frequency,
                customDays: schedule.customDays,
                notificationsEnabled: schedule.notificationsEnabled,
                label: schedule.label ?? ""
            )
        }
    }

    private func saveRoutine() {
        guard canSave else { return }

        HapticFeedback.buttonPress()

        let routine: Routine
        if let existing = existingRoutine {
            // Update existing routine
            routine = existing
            routine.name = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
            routine.routineDescription = routineDescription.isEmpty ? nil : routineDescription
            routine.iconName = selectedIcon
            routine.colorHex = selectedColor
            routine.isActive = isActive
            routine.updatedAt = Date()

            // Remove old schedules and add new ones
            for schedule in routine.schedules {
                modelContext.delete(schedule)
            }
            routine.schedules = []
        } else {
            // Create new routine
            routine = Routine(
                name: routineName.trimmingCharacters(in: .whitespacesAndNewlines),
                routineDescription: routineDescription.isEmpty ? nil : routineDescription,
                isActive: isActive,
                colorHex: selectedColor,
                iconName: selectedIcon
            )
            modelContext.insert(routine)
        }

        // Create and add schedules
        for scheduleData in schedules {
            let schedule = Schedule(
                time: scheduleData.time,
                frequency: scheduleData.frequency,
                customDays: scheduleData.customDays,
                notificationsEnabled: scheduleData.notificationsEnabled,
                label: scheduleData.label.isEmpty ? nil : scheduleData.label,
                routine: routine
            )
            routine.schedules.append(schedule)
        }

        do {
            try modelContext.save()
            HapticFeedback.success()
            onSave?(routine)
            dismiss()
        } catch {
            print("Failed to save routine: \(error)")
            HapticFeedback.error()
            validationMessage = "Failed to save routine. Please try again."
            showValidationError = true
        }
    }
}

// MARK: - Schedule Data (for editing)

/// Temporary data structure for editing schedules before saving
struct ScheduleData: Identifiable {
    let id = UUID()
    var time: Date
    var frequency: ScheduleFrequency
    var customDays: [DayOfWeek]
    var notificationsEnabled: Bool
    var label: String

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    init(
        time: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        frequency: ScheduleFrequency = .daily,
        customDays: [DayOfWeek] = [],
        notificationsEnabled: Bool = true,
        label: String = ""
    ) {
        self.time = time
        self.frequency = frequency
        self.customDays = customDays
        self.notificationsEnabled = notificationsEnabled
        self.label = label
    }
}

// Make Int identifiable for sheet binding
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

// MARK: - Add Schedule Sheet

struct AddScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var time = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var frequency: ScheduleFrequency = .daily
    @State private var customDays: [DayOfWeek] = []
    @State private var notificationsEnabled = true
    @State private var label = ""

    var onSave: (ScheduleData) -> Void

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Add Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TextColors.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let scheduleData = ScheduleData(
                            time: time,
                            frequency: frequency,
                            customDays: customDays,
                            notificationsEnabled: notificationsEnabled,
                            label: label
                        )
                        onSave(scheduleData)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AccentColors.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Edit Schedule Sheet

struct EditScheduleSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var time: Date
    @State private var frequency: ScheduleFrequency
    @State private var customDays: [DayOfWeek]
    @State private var notificationsEnabled: Bool
    @State private var label: String

    var onSave: (ScheduleData) -> Void
    var onDelete: () -> Void

    init(scheduleData: ScheduleData, onSave: @escaping (ScheduleData) -> Void, onDelete: @escaping () -> Void) {
        _time = State(initialValue: scheduleData.time)
        _frequency = State(initialValue: scheduleData.frequency)
        _customDays = State(initialValue: scheduleData.customDays)
        _notificationsEnabled = State(initialValue: scheduleData.notificationsEnabled)
        _label = State(initialValue: scheduleData.label)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
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

                        // Delete button
                        Button(action: {
                            HapticFeedback.buttonPress()
                            onDelete()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Schedule")
                            }
                            .font(AppFonts.regularBody)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(BackgroundColors.tertiary)
                            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TextColors.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let scheduleData = ScheduleData(
                            time: time,
                            frequency: frequency,
                            customDays: customDays,
                            notificationsEnabled: notificationsEnabled,
                            label: label
                        )
                        onSave(scheduleData)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AccentColors.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview("Add Routine") {
    AddRoutineView()
        .modelContainer(for: [Routine.self, Schedule.self], inMemory: true)
}
