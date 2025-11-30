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
//  - Handles deep linking from Lock Screen widget
//

import SwiftUI
import SwiftData
import WidgetKit
import Combine

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
            Category.self,
            RotationState.self
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

// MARK: - Deep Link Handler
/// Manages deep link navigation from Lock Screen widget
/// URL format: hopecore://message/{messageID}
class DeepLinkHandler: ObservableObject {
    static let shared = DeepLinkHandler()
    
    /// Message ID to navigate to when app opens
    @Published var pendingMessageID: UUID?
    
    /// Parse deep link URL and extract message ID
    /// - Parameter url: URL from widget tap
    /// - Returns: true if URL was handled
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        print("🔗 DeepLinkHandler: Received URL: \(url.absoluteString)")
        print("   Scheme: \(url.scheme ?? "nil")")
        print("   Host: \(url.host ?? "nil")")
        print("   Path: \(url.path)")
        print("   PathComponents: \(url.pathComponents)")
        
        guard url.scheme == "hopecore" else {
            print("⚠️ DeepLinkHandler: Unknown URL scheme: \(url.scheme ?? "nil")")
            return false
        }
        
        // Parse: hopecore://message/{messageID}
        // Try multiple parsing methods for robustness
        var messageIDString: String?
        
        // Method 1: Check if host is "message" and get path
        if url.host == "message" {
            // Remove leading "/" from path
            let path = url.path
            messageIDString = path.hasPrefix("/") ? String(path.dropFirst()) : path
        }
        
        // Method 2: If that didn't work, try pathComponents
        if messageIDString == nil || messageIDString?.isEmpty == true {
            messageIDString = url.pathComponents.dropFirst().first
        }
        
        // Method 3: Try parsing from absolute string
        if messageIDString == nil || messageIDString?.isEmpty == true {
            let components = url.absoluteString.components(separatedBy: "/")
            if components.count >= 4 && components[2].hasSuffix("message") {
                messageIDString = components.last
            }
        }
        
        guard let idString = messageIDString,
              !idString.isEmpty,
              let messageID = UUID(uuidString: idString) else {
            print("❌ DeepLinkHandler: Failed to parse message ID from URL")
            print("   Attempted ID string: \(messageIDString ?? "nil")")
            return false
        }
        
        print("✅ DeepLinkHandler: Parsed message ID: \(messageID)")
        pendingMessageID = messageID
        return true
    }
    
    /// Clear pending navigation after handling
    func clearPendingNavigation() {
        pendingMessageID = nil
    }
}

// MARK: - App Root View

/// Root view that determines which screen to show based on onboarding status
/// AGENT NOTE: Checks UserPreferences to route to onboarding or main app
/// Handles deep linking from Lock Screen widget
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var preferences: [UserPreferences]
    @StateObject private var deepLinkHandler = DeepLinkHandler.shared

    var body: some View {
        Group {
            if let userPrefs = preferences.first {
                if userPrefs.hasCompletedOnboarding {
                    HomeView(initialMessageID: deepLinkHandler.pendingMessageID)
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
            
            // Ensure widget has data on app launch
            ensureWidgetHasData()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Schedule background tasks when app goes to background
            // AGENT NOTE: Phase 3 - Schedule daily image prefetch
            if newPhase == .background {
                BackgroundTaskManager.shared.scheduleDailyImagePrefetch()
            }
            
            // Refresh widget data when app becomes active
            if newPhase == .active {
                MessageService.shared.refreshWidgetData()
            }
        }
        .onOpenURL { url in
            // Handle deep link from widget tap
            // AGENT NOTE: URL format is hopecore://message/{messageID}
            deepLinkHandler.handleURL(url)
        }
    }
    
    /// Ensure widget has message data on first launch
    private func ensureWidgetHasData() {
        // Check if widget data store is empty
        if WidgetDataStore.getTodaysMessage() == nil {
            // Load messages and set featured message for widget
            MessageService.shared.loadMessages(from: modelContext)
            
            if let prefs = preferences.first {
                MessageService.shared.selectTodaysFeaturedMessage(
                    preferences: prefs,
                    modelContext: modelContext
                )
            } else {
                // Fallback: just refresh with whatever is available
                MessageService.shared.refreshWidgetData()
            }
        }
    }
}
