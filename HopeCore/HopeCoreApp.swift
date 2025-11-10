//
//  HopeCoreApp.swift
//  HopeCore
//
//  Created by Reed Rawlings on 11/10/25.
//
//  Main App Entry Point
//  AGENT NOTES:
//  - Configures SwiftData with all app models
//  - Initializes singleton services (NotificationManager, AudioManager, etc.)
//  - Sets up proper data persistence
//  - Determines initial view based on onboarding status
//

import SwiftUI
import SwiftData

@main
struct HopeCoreApp: App {
    // MARK: - SwiftData Configuration

    /// Shared model container for persistent storage
    /// Contains all app data models
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Message.self,
            AudioTrack.self,
            UserPreferences.self,
            Category.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Initialization

    init() {
        // Initialize services
        _ = NotificationManager.shared
        _ = AudioManager.shared
        _ = ImageCacheManager.shared
        _ = MessageService.shared
        _ = SubscriptionManager.shared

        // Configure app appearance
        configureAppearance()
    }

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            // AGENT NOTE: Replace ContentView with proper app entry point
            // Should show OnboardingView if !hasCompletedOnboarding
            // Otherwise show HomeView
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Appearance Configuration

    /// Configure global app appearance
    /// Sets up navigation bar styling, tab bar, etc.
    private func configureAppearance() {
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(BackgroundColors.primary)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(TextColors.primary)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(TextColors.primary)
        ]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        // Tab bar appearance (if using tabs)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(BackgroundColors.primary)

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
