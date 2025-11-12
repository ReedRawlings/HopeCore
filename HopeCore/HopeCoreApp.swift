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
            // CRITICAL FIX: Replace fatalError with graceful error handling
            // Log the error for debugging
            print("❌ CRITICAL ERROR: Could not create ModelContainer: \(error)")
            print("Error details: \(error.localizedDescription)")

            // Try to create an in-memory fallback container
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            do {
                print("⚠️ Attempting to create in-memory fallback ModelContainer...")
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // Last resort: This should rarely happen, but if it does,
                // we need to crash gracefully with proper error reporting
                print("❌ FATAL: Could not create fallback ModelContainer: \(error)")
                fatalError("Unable to initialize data storage. Please reinstall the app. Error: \(error)")
            }
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
        _ = BackgroundTaskManager.shared

        // Register background tasks
        // AGENT NOTE: Phase 3 - Background task for daily image pre-loading
        BackgroundTaskManager.shared.registerBackgroundTasks()

        // Configure app appearance
        HopeCoreApp.configureAppearance()
    }

    // MARK: - Appearance Configuration

    /// Configure global app appearance
    /// Sets up navigation bar styling, tab bar, etc.
    private static func configureAppearance() {
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

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App Root View

/// Root view that determines which screen to show based on onboarding status
/// AGENT NOTE: Checks UserPreferences to route to onboarding or main app
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var preferences: [UserPreferences]

    var body: some View {
        Group {
            if let userPrefs = preferences.first {
                if userPrefs.hasCompletedOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            } else {
                // No preferences exist yet, show onboarding
                OnboardingView()
            }
        }
        .onAppear {
            // Create default preferences if none exist
            if preferences.isEmpty {
                let defaultPrefs = UserPreferences()
                modelContext.insert(defaultPrefs)
                try? modelContext.save()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Schedule background tasks when app goes to background
            // AGENT NOTE: Phase 3 - Schedule daily image prefetch
            if newPhase == .background {
                BackgroundTaskManager.shared.scheduleDailyImagePrefetch()
            }
        }
    }
}
