//
//  RoutineListView.swift
//  HopeCore
//
//  View - Routines Library/List
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Main view for managing all user routines
//  - Displays routines in a list/card format
//  - Allows creating, editing, and deleting routines
//  - Toggle routine active state with quick action
//  - Empty state for first-time users
//  - Integrates with SwiftData for persistence
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Query

    @Query(sort: \Routine.sortOrder) private var routines: [Routine]

    // MARK: - State

    @State private var showAddRoutine = false
    @State private var routineToEdit: Routine?
    @State private var routineToDelete: Routine?
    @State private var showDeleteConfirmation = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColors.primary
                    .ignoresSafeArea()

                if routines.isEmpty {
                    emptyStateView
                } else {
                    routinesList
                }
            }
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        HapticFeedback.buttonPress()
                        dismiss()
                    }
                    .foregroundColor(TextColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticFeedback.buttonPress()
                        showAddRoutine = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(AccentColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddRoutine) {
                AddRoutineView()
            }
            .sheet(item: $routineToEdit) { routine in
                AddRoutineView(existingRoutine: routine)
            }
            .alert("Delete Routine", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    routineToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let routine = routineToDelete {
                        deleteRoutine(routine)
                    }
                }
            } message: {
                if let routine = routineToDelete {
                    Text("Are you sure you want to delete \"\(routine.name)\"? This action cannot be undone.")
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(TextColors.tertiary)

            Text("No routines yet")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            Text("Create routines to receive motivational messages at specific times")
                .supportingTextStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)

            Button(action: {
                HapticFeedback.buttonPress()
                showAddRoutine = true
            }) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Your First Routine")
                }
                .font(AppFonts.buttonPrimary)
                .foregroundColor(TextColors.inverse)
                .padding(.horizontal, Spacing.xl)
                .frame(height: ComponentSpacing.primaryButtonHeight)
                .background(AccentColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Routines List

    private var routinesList: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Header info
                HStack {
                    Text("\(routines.count) routine\(routines.count == 1 ? "" : "s")")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.secondary)

                    Spacer()

                    let activeCount = routines.filter { $0.isActive }.count
                    Text("\(activeCount) active")
                        .font(AppFonts.smallBody)
                        .foregroundColor(AccentColors.primary)
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
                .padding(.top, Spacing.sm)

                // Routine cards
                ForEach(routines) { routine in
                    RoutineCard(
                        routine: routine,
                        onTap: {
                            routineToEdit = routine
                        },
                        onToggle: {
                            toggleRoutine(routine)
                        },
                        onDelete: {
                            routineToDelete = routine
                            showDeleteConfirmation = true
                        }
                    )
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
            }
            .padding(.vertical, Spacing.lg)
        }
    }

    // MARK: - Actions

    private func toggleRoutine(_ routine: Routine) {
        routine.toggleActive()
        try? modelContext.save()
        HapticFeedback.selection()
    }

    private func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
        try? modelContext.save()
        routineToDelete = nil
        HapticFeedback.medium()
    }
}

// MARK: - Routine Card

struct RoutineCard: View {
    let routine: Routine
    let onTap: () -> Void
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon
                iconView

                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(routine.name)
                        .font(AppFonts.subtitle)
                        .foregroundColor(routine.isActive ? TextColors.primary : TextColors.tertiary)

                    if let description = routine.routineDescription, !description.isEmpty {
                        Text(description)
                            .font(AppFonts.smallBody)
                            .foregroundColor(TextColors.secondary)
                            .lineLimit(1)
                    }

                    // Schedule summary
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(routine.scheduleSummary)
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(routine.isActive ? accentColor.opacity(0.8) : TextColors.tertiary)
                }

                Spacer()

                // Toggle
                Toggle("", isOn: Binding(
                    get: { routine.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(accentColor)
            }
            .padding(Spacing.md)
            .background(BackgroundColors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: ComponentSpacing.cardCornerRadius)
                    .stroke(routine.isActive ? accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .opacity(routine.isActive ? 1 : 0.7)
        }
        .buttonStyle(RoutineCardButtonStyle())
        .contextMenu {
            Button(action: onTap) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: onToggle) {
                Label(
                    routine.isActive ? "Disable" : "Enable",
                    systemImage: routine.isActive ? "pause.circle" : "play.circle"
                )
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var accentColor: Color {
        if let colorHex = routine.colorHex {
            return Color(hex: colorHex)
        }
        return AccentColors.primary
    }

    private var iconView: some View {
        Image(systemName: routine.iconName ?? "bell.fill")
            .font(.system(size: 24))
            .foregroundColor(routine.isActive ? accentColor : TextColors.tertiary)
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(routine.isActive ? accentColor.opacity(0.15) : BackgroundColors.tertiary)
            )
    }
}

// MARK: - Routine Card Button Style

struct RoutineCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: AnimationTiming.quick), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Routine List - With Content") {
    let container = try! ModelContainer(
        for: Routine.self, Schedule.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Add sample data
    for routine in Routine.sampleRoutines {
        container.mainContext.insert(routine)
    }

    return RoutineListView()
        .modelContainer(container)
}

#Preview("Routine List - Empty") {
    RoutineListView()
        .modelContainer(for: [Routine.self, Schedule.self], inMemory: true)
}
