//
//  OnboardingView.swift
//  HopeCore
//
//  View - Onboarding Flow
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Multi-step onboarding flow for first-time users
//  - Collects user situation, rebuilding areas, notification preferences
//  - Explains demotivation messages for free users
//  - Requests notification permissions
//  - Saves preferences to UserPreferences model
//  - Sets hasCompletedOnboarding = true on completion
//  - Uses smooth transitions between screens
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    /// Current onboarding step (0-4)
    @State private var currentStep = 0

    /// User situation selection
    @State private var userSituation = ""

    /// Selected rebuilding areas
    @State private var selectedAreas: Set<String> = []

    /// Messages per day
    @State private var messagesPerDay = 3

    /// Notification start time
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()

    /// Notification end time
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()

    /// Selected background image for textOverlay quotes
    @State private var selectedBackgroundImage = Constants.Defaults.defaultBackgroundImage

    /// Selected font ID for message display
    @State private var selectedFontID = FontManager.defaultFontID

    /// Onboarding complete
    @State private var isComplete = false

    // MARK: - Constants

    private let totalSteps = 7

    private let situations = [
        "Recovery journey",
        "Career transition",
        "Personal growth",
        "Starting fresh",
        "Building resilience",
        "Other"
    ]

    private let rebuildingAreas = [
        "Health & wellness",
        "Relationships",
        "Career & work",
        "Financial stability",
        "Mental health",
        "Personal identity",
        "Daily habits",
        "Purpose & meaning"
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            BackgroundColors.primary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar

                // Content
                TabView(selection: $currentStep) {
                    welcomeStep
                        .tag(0)

                    situationStep
                        .tag(1)

                    backgroundImageStep
                        .tag(2)

                    fontSelectionStep
                        .tag(3)

                    notificationTimingStep
                        .tag(4)

                    demotivationStep
                        .tag(5)

                    permissionsStep
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth, value: currentStep)
            }
        }
        .onChange(of: isComplete) { _, complete in
            if complete {
                completeOnboarding()
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(BackgroundColors.tertiary)
                        .frame(height: 4)

                    // Progress
                    Rectangle()
                        .fill(AccentColors.primary)
                        .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 4)
                        .animation(.smooth, value: currentStep)
                }
            }
            .frame(height: 4)
        }
        .padding(.bottom, Spacing.xl)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AccentColors.primary)

            // Title
            Text("Welcome to HopeCore")
                .font(AppFonts.display)
                .foregroundColor(TextColors.primary)

            // Description
            Text("Your daily companion for rebuilding and finding possibility in the everyday.")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)

            Spacer()

            // Continue Button
            Button(action: {
                HapticFeedback.buttonPress()
                withAnimation {
                    currentStep = 1
                }
            }) {
                Text("Get Started")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)
        }
        .padding(.vertical, ScreenLayout.topMargin)
    }

    // MARK: - Step 2: Situation

    private var situationStep: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("What brought you here?")
                    .font(AppFonts.title)
                    .foregroundColor(TextColors.primary)

                Text("This helps us understand your journey")
                    .supportingTextStyle()
            }
            .padding(.top, Spacing.xl)

            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(situations, id: \.self) { situation in
                        Button(action: {
                            HapticFeedback.selection()
                            userSituation = situation
                        }) {
                            HStack {
                                Text(situation)
                                    .font(AppFonts.regularBody)
                                    .foregroundColor(TextColors.primary)

                                Spacer()

                                if userSituation == situation {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AccentColors.primary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                    .fill(userSituation == situation ? AccentColors.primary.opacity(0.1) : BackgroundColors.elevated)
                            )
                        }
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
            }

            Spacer()

            // Navigation
            navigationButtons(
                canContinue: !userSituation.isEmpty,
                onBack: {
                    withAnimation { currentStep = 0 }
                },
                onContinue: {
                    withAnimation { currentStep = 2 }
                }
            )
        }
    }

    // MARK: - Step 3: Background Image Selection

    private var backgroundImageStep: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("Choose your background")
                    .font(AppFonts.title)
                    .foregroundColor(TextColors.primary)

                Text("All quotes will use this background image")
                    .supportingTextStyle()
            }
            .padding(.top, Spacing.xl)
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                    ForEach(Constants.BackgroundImages.availableImages, id: \.self) { imageName in
                        Button(action: {
                            HapticFeedback.selection()
                            selectedBackgroundImage = imageName
                        }) {
                            ZStack {
                                // Background image preview
                                BundledImageView(imageName: imageName)
                                    .aspectRatio(4/3, contentMode: .fill)
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                            .stroke(
                                                selectedBackgroundImage == imageName ? AccentColors.primary : Color.clear,
                                                lineWidth: 4
                                            )
                                    )
                                
                                // Selection indicator
                                if selectedBackgroundImage == imageName {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(AccentColors.primary)
                                                .background(Circle().fill(BackgroundColors.primary))
                                                .padding(Spacing.xs)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, ScreenLayout.horizontalMargin)
            }

            Spacer()

            // Navigation
            navigationButtons(
                canContinue: true,
                onBack: {
                    withAnimation { currentStep = 1 }
                },
                onContinue: {
                    withAnimation { currentStep = 3 }
                }
            )
        }
    }

    // MARK: - Step 4: Font Selection

    private var fontSelectionStep: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("Choose your font")
                    .font(AppFonts.title)
                    .foregroundColor(TextColors.primary)

                Text("This font will be used for all quotes")
                    .supportingTextStyle()
            }
            .padding(.top, Spacing.xl)
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    ForEach(FontCategory.allCases, id: \.self) { category in
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text(category.rawValue)
                                .font(AppFonts.smallBody)
                                .foregroundColor(TextColors.tertiary)
                                .padding(.horizontal, ScreenLayout.horizontalMargin)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.md) {
                                    ForEach(FontManager.shared.fonts(in: category)) { font in
                                        Button(action: {
                                            HapticFeedback.selection()
                                            selectedFontID = font.id
                                        }) {
                                            VStack(spacing: Spacing.xs) {
                                                // Font preview
                                                Text(font.previewText)
                                                    .font(font.font(size: 16))
                                                    .foregroundColor(TextColors.primary)
                                                    .lineLimit(1)
                                                    .frame(width: 140, height: 50)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                                            .fill(BackgroundColors.elevated)
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                                            .stroke(
                                                                selectedFontID == font.id ? AccentColors.primary : Color.clear,
                                                                lineWidth: 3
                                                            )
                                                    )

                                                // Font name
                                                Text(font.displayName)
                                                    .font(AppFonts.caption)
                                                    .foregroundColor(selectedFontID == font.id ? AccentColors.primary : TextColors.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, ScreenLayout.horizontalMargin)
                            }
                        }
                    }
                }
            }

            // Preview of selected font
            VStack(spacing: Spacing.sm) {
                Text("Preview")
                    .font(AppFonts.caption)
                    .foregroundColor(TextColors.tertiary)

                Text("You weren't put here to be average")
                    .font(FontManager.shared.font(for: selectedFontID).font(size: 20, weight: .medium))
                    .foregroundColor(TextColors.primary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(BackgroundColors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            Spacer()

            // Navigation
            navigationButtons(
                canContinue: true,
                onBack: {
                    withAnimation { currentStep = 2 }
                },
                onContinue: {
                    withAnimation { currentStep = 4 }
                }
            )
        }
    }

    // MARK: - Step 5: Notification Timing

    private var notificationTimingStep: some View {
        VStack(spacing: Spacing.xl) {
            VStack(spacing: Spacing.sm) {
                Text("When should we send messages?")
                    .font(AppFonts.title)
                    .foregroundColor(TextColors.primary)
                    .multilineTextAlignment(.center)

                Text("Choose your active hours")
                    .supportingTextStyle()
            }
            .padding(.top, Spacing.xl)
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            VStack(spacing: Spacing.lg) {
                // Messages per day
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Messages per day: \(messagesPerDay)")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)

                    HStack {
                        Text("1")
                            .supportingTextStyle()
                        Slider(value: Binding(
                            get: { Double(messagesPerDay) },
                            set: { messagesPerDay = Int($0) }
                        ), in: 1...5, step: 1)
                        .tint(AccentColors.primary)
                        .onChange(of: messagesPerDay) { _, _ in
                            HapticFeedback.selection()
                        }
                        Text("5")
                            .supportingTextStyle()
                    }

                    Text("Free tier: up to 5 messages per day")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.tertiary)
                }
                .padding()
                .background(BackgroundColors.elevated)
                .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))

                // Start time
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Start time")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)

                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                .padding()
                .background(BackgroundColors.elevated)
                .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))

                // End time
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("End time")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)

                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                .padding()
                .background(BackgroundColors.elevated)
                .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            Spacer()

            // Navigation
            navigationButtons(
                canContinue: true,
                onBack: {
                    withAnimation { currentStep = 3 }
                },
                onContinue: {
                    withAnimation { currentStep = 5 }
                }
            )
        }
    }

    // MARK: - Step 6: Demotivation Explanation

    private var demotivationStep: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(AccentColors.warmth)

            // Title
            Text("About the Free Experience")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            // Description
            VStack(spacing: Spacing.md) {
                Text("As a free user, you'll occasionally receive challenging messages designed to test your resilience.")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.secondary)
                    .multilineTextAlignment(.center)

                Text("For every 5 messages, 1 will be a demotivation message. This is part of the free tier experience.")
                    .font(AppFonts.regularBody)
                    .foregroundColor(TextColors.secondary)
                    .multilineTextAlignment(.center)

                Text("Premium users can disable these messages entirely.")
                    .font(AppFonts.smallBody)
                    .foregroundColor(AccentColors.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.xxl)

            Spacer()

            // Navigation
            navigationButtons(
                canContinue: true,
                onBack: {
                    withAnimation { currentStep = 4 }
                },
                onContinue: {
                    withAnimation { currentStep = 6 }
                }
            )
        }
        .padding(.vertical, ScreenLayout.topMargin)
    }

    // MARK: - Step 7: Permissions

    private var permissionsStep: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(AccentColors.primary)

            // Title
            Text("Enable Notifications")
                .font(AppFonts.title)
                .foregroundColor(TextColors.primary)

            // Description
            Text("Receive your daily hopecore messages at the times you've chosen.")
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)

            Spacer()

            // Complete Button
            Button(action: {
                HapticFeedback.buttonPress()
                requestNotificationPermission()
            }) {
                Text("Enable Notifications")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, ScreenLayout.horizontalMargin)

            // Skip Button
            Button(action: {
                HapticFeedback.buttonPress()
                isComplete = true
            }) {
                Text("Skip for now")
                    .font(AppFonts.buttonSecondary)
                    .foregroundColor(TextColors.secondary)
            }
        }
        .padding(.vertical, ScreenLayout.topMargin)
    }

    // MARK: - Navigation Buttons

    private func navigationButtons(
        canContinue: Bool,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) -> some View {
        HStack(spacing: Spacing.sm) {
            // Back Button
            Button(action: {
                HapticFeedback.buttonPress()
                onBack()
            }) {
                Text("Back")
                    .secondaryButtonStyle()
            }

            // Continue Button
            Button(action: {
                HapticFeedback.buttonPress()
                onContinue()
            }) {
                Text("Continue")
                    .primaryButtonStyle()
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.5)
        }
        .padding(.horizontal, ScreenLayout.horizontalMargin)
        .padding(.bottom, ScreenLayout.bottomMargin)
    }

    // MARK: - Actions

    /// Request notification permission
    /// AGENT NOTE: Requests notification authorization via NotificationManager
    private func requestNotificationPermission() {
        Task {
            do {
                // Request notification authorization
                try await NotificationManager.shared.requestAuthorization()

                // Complete onboarding after permission request
                await MainActor.run {
                    isComplete = true
                }
            } catch {
                print("Failed to request notification authorization: \(error)")

                // Still complete onboarding even if permission denied
                await MainActor.run {
                    isComplete = true
                }
            }
        }
    }

    /// Complete onboarding and save preferences
    /// AGENT NOTE: Saves preferences and schedules initial notifications
    private func completeOnboarding() {
        // Create or fetch UserPreferences
        let descriptor = FetchDescriptor<UserPreferences>()

        do {
            let existingPrefs = try modelContext.fetch(descriptor)
            let prefs = existingPrefs.first ?? UserPreferences()

            // Update preferences
            prefs.hasCompletedOnboarding = true
            prefs.userSituation = userSituation
            prefs.rebuildingAreas = Array(selectedAreas)
            prefs.defaultBackgroundImage = selectedBackgroundImage
            prefs.selectedFontID = selectedFontID
            prefs.messagesPerDay = messagesPerDay
            prefs.notificationStartTime = startTime
            prefs.notificationEndTime = endTime

            // Insert if new
            if existingPrefs.isEmpty {
                modelContext.insert(prefs)
            }

            // Save
            try modelContext.save()

            // Schedule initial notifications if permission granted
            Task {
                await scheduleInitialNotifications(preferences: prefs)
            }

            // Schedule background task for daily image prefetch
            // AGENT NOTE: Phase 3 - Background task scheduling after onboarding
            BackgroundTaskManager.shared.scheduleDailyImagePrefetch()

            // Haptic feedback
            HapticFeedback.success()

        } catch {
            print("Failed to save onboarding preferences: \(error)")
        }
    }

    /// Schedule initial notifications after onboarding
    private func scheduleInitialNotifications(preferences: UserPreferences) async {
        guard NotificationManager.shared.notificationsEnabled else {
            print("Notifications not enabled, skipping schedule")
            return
        }

        // Load messages from SwiftData
        let messageService = MessageService.shared
        messageService.loadMessages(from: modelContext)

        // Get filtered messages
        let messages = messageService.filteredMessages

        do {
            // Schedule notifications based on preferences
            try await NotificationManager.shared.scheduleNotifications(
                preferences: preferences,
                messages: messages,
                modelContext: modelContext
            )
            print("Initial notifications scheduled successfully")
        } catch {
            print("Failed to schedule initial notifications: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
