//
//  SettingsView.swift
//  HopeCore
//
//  View - Settings and Preferences
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - User preferences for notifications, subscription, sounds
//  - Premium subscription upsell for free users
//  - Toggle demotivation messages (premium only)
//  - Notification frequency and timing controls
//  - Quiet hours configuration
//  - Sound and haptic preferences
//  - Reschedules notifications when settings change
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Query

    @Query private var preferences: [UserPreferences]

    // MARK: - State

    @State private var showPremiumSheet = false
    @State private var settingsChanged = false

    // MARK: - Computed

    private var userPrefs: UserPreferences? {
        preferences.first
    }

    private var isPremium: Bool {
        userPrefs?.isPremium ?? false
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColors.primary
                    .ignoresSafeArea()

                Form {
                    // Premium Section
                    if !isPremium {
                        premiumSection
                    }

                    // Notification Settings
                    notificationSection

                    // Quiet Hours
                    quietHoursSection

                    // Message Preferences
                    messagePreferencesSection

                    // Sound & Haptic
                    soundHapticSection

                    // About
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticFeedback.buttonPress()
                        if settingsChanged {
                            saveSettings()
                        }
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPremiumSheet) {
                premiumUpsellSheet
            }
        }
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        Section {
            Button(action: {
                HapticFeedback.buttonPress()
                showPremiumSheet = true
            }) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AccentColors.warmth)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Upgrade to Premium")
                            .font(AppFonts.subtitle)
                            .foregroundColor(TextColors.primary)

                        Text("Unlock 20 messages/day, remove demotivation messages, and more")
                            .font(AppFonts.smallBody)
                            .foregroundColor(TextColors.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(TextColors.tertiary)
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section {
            if let prefs = userPrefs {
                // Messages per day
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Messages per day: \(prefs.messagesPerDay)")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)

                    HStack {
                        Text("1")
                            .supportingTextStyle()
                        Slider(
                            value: Binding(
                                get: { Double(prefs.messagesPerDay) },
                                set: { newValue in
                                    prefs.messagesPerDay = Int(newValue)
                                    settingsChanged = true
                                    HapticFeedback.selection()
                                }
                            ),
                            in: 1...Double(prefs.tier.maxMessagesPerDay),
                            step: 1
                        )
                        .tint(AccentColors.primary)
                        Text("\(prefs.tier.maxMessagesPerDay)")
                            .supportingTextStyle()
                    }

                    if !isPremium {
                        Text("Upgrade to Premium for up to 20 messages/day")
                            .font(AppFonts.caption)
                            .foregroundColor(AccentColors.primary)
                    }
                }

                // Start time
                DatePicker(
                    "Start time",
                    selection: Binding(
                        get: { prefs.notificationStartTime },
                        set: { newValue in
                            prefs.notificationStartTime = newValue
                            settingsChanged = true
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .foregroundColor(TextColors.primary)

                // End time
                DatePicker(
                    "End time",
                    selection: Binding(
                        get: { prefs.notificationEndTime },
                        set: { newValue in
                            prefs.notificationEndTime = newValue
                            settingsChanged = true
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .foregroundColor(TextColors.primary)
            }
        } header: {
            Text("Notifications")
                .foregroundColor(TextColors.secondary)
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - Quiet Hours Section

    private var quietHoursSection: some View {
        Section {
            if let prefs = userPrefs {
                Toggle(
                    "Enable quiet hours",
                    isOn: Binding(
                        get: { prefs.quietHoursEnabled },
                        set: { newValue in
                            prefs.quietHoursEnabled = newValue
                            settingsChanged = true
                            HapticFeedback.selection()
                        }
                    )
                )
                .tint(AccentColors.primary)
                .foregroundColor(TextColors.primary)

                if prefs.quietHoursEnabled {
                    DatePicker(
                        "Quiet hours start",
                        selection: Binding(
                            get: { prefs.quietHoursStart ?? Date() },
                            set: { newValue in
                                prefs.quietHoursStart = newValue
                                settingsChanged = true
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .foregroundColor(TextColors.primary)

                    DatePicker(
                        "Quiet hours end",
                        selection: Binding(
                            get: { prefs.quietHoursEnd ?? Date() },
                            set: { newValue in
                                prefs.quietHoursEnd = newValue
                                settingsChanged = true
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .foregroundColor(TextColors.primary)

                    Text("No notifications will be sent during quiet hours")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.tertiary)
                }
            }
        } header: {
            Text("Quiet Hours")
                .foregroundColor(TextColors.secondary)
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - Message Preferences Section

    private var messagePreferencesSection: some View {
        Section {
            if let prefs = userPrefs {
                // Background image selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Background Image")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)
                    
                    Text("All quotes will use this background")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.tertiary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            ForEach(Constants.BackgroundImages.availableImages, id: \.self) { imageName in
                                Button(action: {
                                    HapticFeedback.selection()
                                    prefs.defaultBackgroundImage = imageName
                                    settingsChanged = true
                                }) {
                                    ZStack {
                                        // Background image preview
                                        BundledImageView(imageName: imageName)
                                            .aspectRatio(4/3, contentMode: .fill)
                                            .frame(width: 100, height: 75)
                                            .clipShape(RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                                    .stroke(
                                                        (prefs.defaultBackgroundImage ?? Constants.Defaults.defaultBackgroundImage) == imageName ? AccentColors.primary : Color.clear,
                                                        lineWidth: 3
                                                    )
                                            )
                                        
                                        // Selection indicator
                                        if (prefs.defaultBackgroundImage ?? Constants.Defaults.defaultBackgroundImage) == imageName {
                                            VStack {
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 16))
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
                        .padding(.horizontal, Spacing.xs)
                    }
                }
                .padding(.vertical, Spacing.xs)

                // Font selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Quote Font")
                        .font(AppFonts.regularBody)
                        .foregroundColor(TextColors.primary)

                    Text("Font used for displaying quotes")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.tertiary)

                    // Current font preview
                    let currentFont = FontManager.shared.font(for: prefs.selectedFontID ?? FontManager.defaultFontID)
                    Text(currentFont.displayName)
                        .font(currentFont.font(size: 15))
                        .foregroundColor(TextColors.secondary)
                        .padding(.vertical, Spacing.xs)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.md) {
                            ForEach(FontManager.shared.availableFonts) { font in
                                Button(action: {
                                    HapticFeedback.selection()
                                    prefs.selectedFontID = font.id
                                    settingsChanged = true
                                }) {
                                    VStack(spacing: Spacing.xs) {
                                        // Font preview
                                        Text(font.previewText)
                                            .font(font.font(size: 14))
                                            .foregroundColor(TextColors.primary)
                                            .lineLimit(1)
                                            .frame(width: 100, height: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                                    .fill(BackgroundColors.tertiary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: ComponentSpacing.smallCornerRadius)
                                                    .stroke(
                                                        (prefs.selectedFontID ?? FontManager.defaultFontID) == font.id ? AccentColors.primary : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )

                                        // Font name
                                        Text(font.displayName)
                                            .font(AppFonts.caption)
                                            .foregroundColor((prefs.selectedFontID ?? FontManager.defaultFontID) == font.id ? AccentColors.primary : TextColors.tertiary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xs)
                    }
                }
                .padding(.vertical, Spacing.xs)

                // Demotivation toggle (premium only)
                if isPremium {
                    Toggle(
                        "Enable demotivation messages",
                        isOn: Binding(
                            get: { prefs.demotivationEnabled },
                            set: { newValue in
                                prefs.demotivationEnabled = newValue
                                settingsChanged = true
                                HapticFeedback.selection()
                            }
                        )
                    )
                    .tint(AccentColors.primary)
                    .foregroundColor(TextColors.primary)

                    Text("Occasional challenging messages to test resilience")
                        .font(AppFonts.caption)
                        .foregroundColor(TextColors.tertiary)
                } else {
                    HStack {
                        Text("Demotivation messages")
                            .foregroundColor(TextColors.primary)
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(TextColors.tertiary)
                    }

                    Text("Free users receive 1 demotivation message for every 5 messages. Upgrade to Premium to disable.")
                        .font(AppFonts.caption)
                        .foregroundColor(AccentColors.primary)
                }
            }
        } header: {
            Text("Message Preferences")
                .foregroundColor(TextColors.secondary)
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - Sound & Haptic Section

    private var soundHapticSection: some View {
        Section {
            if let prefs = userPrefs {
                Toggle(
                    "Notification sounds",
                    isOn: Binding(
                        get: { prefs.notificationSoundEnabled },
                        set: { newValue in
                            prefs.notificationSoundEnabled = newValue
                            settingsChanged = true
                            HapticFeedback.selection()
                        }
                    )
                )
                .tint(AccentColors.primary)
                .foregroundColor(TextColors.primary)

                Toggle(
                    "Haptic feedback",
                    isOn: Binding(
                        get: { prefs.notificationHapticEnabled },
                        set: { newValue in
                            prefs.notificationHapticEnabled = newValue
                            settingsChanged = true
                            HapticFeedback.selection()
                        }
                    )
                )
                .tint(AccentColors.primary)
                .foregroundColor(TextColors.primary)
            }
        } header: {
            Text("Sound & Haptic")
                .foregroundColor(TextColors.secondary)
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            if let prefs = userPrefs {
                HStack {
                    Text("Version")
                        .foregroundColor(TextColors.primary)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(TextColors.tertiary)
                }

                HStack {
                    Text("Subscription")
                        .foregroundColor(TextColors.primary)
                    Spacer()
                    Text(prefs.tier.displayName)
                        .foregroundColor(isPremium ? AccentColors.warmth : TextColors.tertiary)
                }

                HStack {
                    Text("Messages viewed")
                        .foregroundColor(TextColors.primary)
                    Spacer()
                    Text("\(prefs.totalMessagesViewed)")
                        .foregroundColor(TextColors.tertiary)
                }
            }
        } header: {
            Text("About")
                .foregroundColor(TextColors.secondary)
        }
        .listRowBackground(BackgroundColors.elevated)
    }

    // MARK: - Premium Upsell Sheet

    private var premiumUpsellSheet: some View {
        NavigationStack {
            ZStack {
                BackgroundColors.primary
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    // Icon
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AccentColors.warmth)
                        .padding(.top, Spacing.xxl)

                    // Title
                    Text("Upgrade to Premium")
                        .font(AppFonts.display)
                        .foregroundColor(TextColors.primary)

                    // Features
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        featureRow(icon: "envelope.fill", text: "Up to 20 messages per day")
                        featureRow(icon: "xmark.circle.fill", text: "Disable demotivation messages")
                        featureRow(icon: "sparkles", text: "Priority access to new features")
                        featureRow(icon: "arrow.clockwise", text: "Sync across devices")
                    }
                    .padding(.horizontal, Spacing.xxl)

                    Spacer()

                    // Pricing (placeholder)
                    VStack(spacing: Spacing.sm) {
                        Text("$4.99/month")
                            .font(AppFonts.title)
                            .foregroundColor(TextColors.primary)

                        Text("or $39.99/year (save 33%)")
                            .supportingTextStyle()
                    }

                    // Subscribe Button
                    Button(action: {
                        // AGENT NOTE: Integrate with SubscriptionManager
                        HapticFeedback.buttonPress()
                    }) {
                        Text("Subscribe Now")
                            .primaryButtonStyle()
                    }
                    .padding(.horizontal, ScreenLayout.horizontalMargin)

                    // Restore Button
                    Button(action: {
                        // AGENT NOTE: Restore purchases
                        HapticFeedback.buttonPress()
                    }) {
                        Text("Restore Purchases")
                            .font(AppFonts.buttonSecondary)
                            .foregroundColor(TextColors.secondary)
                    }
                    .padding(.bottom, ScreenLayout.bottomMargin)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        showPremiumSheet = false
                    }
                }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AccentColors.primary)
                .frame(width: 32)

            Text(text)
                .font(AppFonts.regularBody)
                .foregroundColor(TextColors.primary)

            Spacer()
        }
    }

    // MARK: - Actions

    /// Save settings and reschedule notifications
    /// AGENT NOTE: Saves preferences and reschedules notifications with updated settings
    private func saveSettings() {
        do {
            try modelContext.save()

            // Reschedule notifications with new settings
            Task {
                await rescheduleNotifications()
            }

            HapticFeedback.success()
            settingsChanged = false
        } catch {
            print("Failed to save settings: \(error)")
            HapticFeedback.error()
        }
    }

    /// Reschedule notifications based on updated preferences
    private func rescheduleNotifications() async {
        guard let prefs = userPrefs else {
            print("No user preferences found")
            return
        }

        guard NotificationManager.shared.notificationsEnabled else {
            print("Notifications not enabled, skipping reschedule")
            return
        }

        // Load messages from SwiftData
        let messageService = MessageService.shared
        messageService.loadMessages(from: modelContext)

        // Get filtered messages
        let messages = messageService.filteredMessages

        do {
            // Reschedule notifications with updated preferences
            try await NotificationManager.shared.scheduleNotifications(
                preferences: prefs,
                messages: messages,
                modelContext: modelContext
            )
            print("Notifications rescheduled successfully")
        } catch {
            print("Failed to reschedule notifications: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .modelContainer(for: [UserPreferences.self], inMemory: true)
}
