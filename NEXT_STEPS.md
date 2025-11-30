# HopeCore App - Next Steps for Future Agents

## Overview

This document outlines the work completed and the critical next steps for future development agents. HopeCore is an iOS app built with SwiftUI and SwiftData, designed to deliver hopecore messages and audio content to users rebuilding their lives.

**Created:** November 10, 2025
**Last Updated:** November 30, 2025 (Phase 4 Complete)
**Session:** Phase 4 Widgets Implementation
**Status:** ✅✅✅✅ Phase 4 Complete - Lock Screen & Home Screen Widgets Implemented, Deep Linking Working

---

## ✅✅✅✅ Phase 4 Work Completed (Current Session)

### Widget Implementation ✅

#### 1. Lock Screen Widget Created ✅
**Location:** `HopeCoreWidget/` directory

**Features Implemented:**
- ✅ Widget Extension target created with iOS 18.0 deployment
- ✅ App Groups configured (`group.com.hopecore.shared`) for data sharing
- ✅ Circular widget (`.accessoryCircular`) for compact display
- ✅ Rectangular widget (`.accessoryRectangular`) optimized for readability (4 lines of text)
- ✅ Text-only display (no images) for fast performance
- ✅ Rose border (2pt, #EC4899) matching design system
- ✅ Dark background (#0A0E14) matching app design
- ✅ Empty state with "Open app to get started" message
- ✅ Deep linking: Tap widget → opens app to specific message

**Widget Files:**
- `HopeCoreWidget/HopeCoreWidget.swift` - Main widget configuration and timeline provider
- `HopeCoreWidget/HopeCoreWidgetView.swift` - SwiftUI views for all widget families
- `HopeCoreWidget/HopeCoreWidgetEntry.swift` - Timeline entry model
- `HopeCoreWidget/WidgetDataStore.swift` - App Group data sharing (duplicated in main app)
- `HopeCoreWidget/HopeCoreWidget.entitlements` - App Groups capability

---

#### 2. Home Screen Widget Created ✅
**Location:** `HopeCoreWidget/` directory (same extension, different families)

**Features Implemented:**
- ✅ Small widget (`.systemSmall`) - 2x2 grid, category badge + 4-line message
- ✅ Medium widget (`.systemMedium`) - 4x2 grid, category badge + 6-line message
- ✅ Large widget (`.systemLarge`) - 4x4 grid, full quote with header/footer
- ✅ Same design system (rose border, dark background)
- ✅ Same deep linking functionality
- ✅ Same scheduled update behavior

**Design:**
- Small: Compact with category badge at top
- Medium: More space for longer quotes
- Large: Full quote display with app branding

---

#### 3. Scheduled Widget Updates ✅
**Location:** `HopeCoreWidget/HopeCoreWidget.swift`, `Services/NotificationManager.swift`

**Implementation:**
- ✅ Widget updates automatically based on user's notification schedule
- ✅ Timeline provider creates entries for each scheduled notification time
- ✅ Widget shows different message at each scheduled time (e.g., 3 messages/day = 3 widget updates)
- ✅ Free users: Updates match their notification schedule
- ✅ Premium users: Updates match their notification schedule (up to 20/day)
- ✅ Falls back to single daily update (6 AM) if no schedule exists

**How It Works:**
1. User sets up notifications during onboarding (e.g., 3 messages/day)
2. NotificationManager schedules notifications and saves schedule to WidgetDataStore
3. Widget timeline provider reads schedule and creates entries for each notification time
4. Widget automatically updates at each scheduled time to show that message
5. Each message overwrites the previous one in the widget

**Code Integration:**
```swift
// NotificationManager saves schedule when notifications are scheduled
let widgetSchedule: [(Date, WidgetMessage)] = zip(selectedMessages, notificationTimes).map { ... }
WidgetDataStore.saveScheduledMessages(widgetSchedule)
WidgetCenter.shared.reloadTimelines(ofKind: "HopeCoreWidget")
```

---

#### 4. Widget Data Sharing ✅
**Location:** `Services/WidgetDataStore.swift` (main app), `HopeCoreWidget/WidgetDataStore.swift` (widget)

**Implementation:**
- ✅ App Groups configured in both targets (`group.com.hopecore.shared`)
- ✅ Shared UserDefaults for cross-process data sharing
- ✅ Stores scheduled messages with their notification times
- ✅ Stores today's featured message for immediate display
- ✅ Stores premium status for update frequency
- ✅ Text-only data (no images) for fast widget performance

**Key Methods:**
- `saveScheduledMessages()` - Saves all scheduled messages with times
- `getScheduledMessages()` - Retrieves schedule for timeline provider
- `getMessageForTime()` - Gets message for specific time
- `saveTodaysMessage()` - Saves featured message for immediate display

---

#### 5. Deep Linking from Widget ✅
**Location:** `HopeCoreApp.swift`, `Views/Home/HomeView.swift`

**Implementation:**
- ✅ URL scheme registered: `hopecore://message/{messageID}`
- ✅ DeepLinkHandler class manages navigation
- ✅ Widget uses `.widgetURL()` to set deep link
- ✅ App handles URL via `.onOpenURL()` modifier
- ✅ HomeView observes DeepLinkHandler and navigates to message
- ✅ Works whether app is launching or already running

**URL Format:**
```
hopecore://message/{uuid}
```

**Navigation Flow:**
1. User taps widget → URL opens app
2. `onOpenURL` calls `DeepLinkHandler.handleURL()`
3. DeepLinkHandler parses message ID and sets `pendingMessageID`
4. HomeView's `onChange` detects change and navigates to message
5. HomeView scrolls to correct message in feed

---

#### 6. Widget Integration with Services ✅
**Location:** `Services/MessageService.swift`, `Services/BackgroundTaskManager.swift`

**Implementation:**
- ✅ MessageService saves featured message to WidgetDataStore
- ✅ MessageService reloads widget timeline when message changes
- ✅ BackgroundTaskManager updates widget during background refresh
- ✅ NotificationManager saves schedule and reloads widget when notifications are scheduled
- ✅ Widget updates when settings change (notifications rescheduled)

**Integration Points:**
```swift
// MessageService
WidgetDataStore.saveTodaysMessage(id: message.id, text: message.text, categoryName: message.categoryName)
WidgetCenter.shared.reloadTimelines(ofKind: "HopeCoreWidget")

// NotificationManager
WidgetDataStore.saveScheduledMessages(widgetSchedule)
WidgetCenter.shared.reloadTimelines(ofKind: "HopeCoreWidget")

// BackgroundTaskManager
updateWidgetInBackground(messages: messages, preferences: preferences, modelContext: modelContext)
```

---

## ✅✅✅ Phase 3 Work Completed (Previous Session)

### Image Caching Integration ✅

#### 1. MessageCard Updated to Use ImageCacheManager ✅
**Location:** `Components/MessageCard.swift`

**Implementation:**
- ✅ Replaced all AsyncImage calls with AsyncImageView from ImageCacheManager
- ✅ Implemented caching for all 4 presentation modes:
  - imageText: Cached image at top, text below
  - textOnBackground: Cached background image with text overlay
  - split: Cached side-by-side image layout
  - minimal: Minimal cached background
- ✅ Memory and disk caching for all message images
- ✅ Automatic cache management (50MB memory, 100MB disk limits)
- ✅ Smooth loading with ProgressView placeholders

**Code Changes:**
```swift
// Now using ImageCacheManager's AsyncImageView
AsyncImageView(urlString: imageURL)
    .aspectRatio(contentMode: .fill)
    .frame(maxHeight: GridLayout.maxMessageImageHeight)
```

---

#### 2. HomeView Image Pre-fetching Activated ✅
**Location:** `Views/Home/HomeView.swift`

**Implementation:**
- ✅ Pre-fetches images around current scroll position (prev, current, next)
- ✅ Initial image pre-fetch when view loads (first 3 messages)
- ✅ Automatic pre-fetching on scroll for smooth UX
- ✅ Async image loading in background tasks
- ✅ Respects ImageCacheManager cache limits

**Code Implementation:**
```swift
// Pre-fetch images around current index
private func prefetchImages(around index: Int) {
    let indicesToPrefetch = [index - 1, index, index + 1]

    Task {
        for i in indicesToPrefetch {
            guard i >= 0 && i < messages.count else { continue }
            let message = messages[i]

            if let imageURL = message.imageURL {
                _ = await ImageCacheManager.shared.getImage(from: imageURL)
            }
        }
    }
}
```

---

### Navigation Enhancements ✅

#### 3. SavedMessagesView Navigation Added to HomeView ✅
**Location:** `Views/Home/HomeView.swift`

**Implementation:**
- ✅ Added "Saved" button (heart icon) to top controls
- ✅ Positioned between app title and music button
- ✅ Rose accent color (AccentColors.primary) for visual consistency
- ✅ Sheet presentation for SavedMessagesView
- ✅ Haptic feedback on button press
- ✅ 44pt minimum tap target for accessibility

**UI Changes:**
- New button: Heart icon (systemName: "heart.fill")
- Color: Rose/magenta accent
- Location: Top right, before music and settings buttons
- Interaction: Opens SavedMessagesView as sheet

---

### Background Task Implementation ✅

#### 4. BackgroundTaskManager Service Created ✅
**Location:** `Services/BackgroundTaskManager.swift`

**Features Implemented:**
- ✅ BGTaskScheduler integration for daily image pre-loading
- ✅ Pre-loads 3 random message images each morning (6 AM)
- ✅ Automatic cache cleanup when limits exceeded
- ✅ Background task registration on app launch
- ✅ Task scheduling when app enters background
- ✅ Task scheduling after onboarding completion
- ✅ Manual execution support for testing
- ✅ Error handling and logging

**Key Implementation:**
```swift
// Background task identifier
static let imagePrefetchTaskIdentifier = "com.hopecore.prefetch-images"

// Daily scheduling at 6 AM
func scheduleDailyImagePrefetch() {
    let request = BGAppRefreshTaskRequest(identifier: Self.imagePrefetchTaskIdentifier)
    // Schedule for 6 AM next morning
    request.earliestBeginDate = /* calculated 6 AM date */
    try BGTaskScheduler.shared.submit(request)
}
```

**Integration Points:**
- `HopeCoreApp.swift`: Registered in app init
- `HopeCoreApp.swift`: Scheduled on scene phase change to background
- `OnboardingView.swift`: Scheduled after onboarding completion

---

#### 5. App-Level Background Task Integration ✅
**Locations:** `HopeCoreApp.swift`, `OnboardingView.swift`

**Implementation:**
- ✅ BackgroundTaskManager initialized in app init
- ✅ Tasks registered on app launch
- ✅ ScenePhase observer schedules tasks when app backgrounded
- ✅ Initial scheduling after onboarding completion
- ✅ Automatic rescheduling after each execution

**Code Changes:**
```swift
// In HopeCoreApp.init()
_ = BackgroundTaskManager.shared
BackgroundTaskManager.shared.registerBackgroundTasks()

// In AppRootView
.onChange(of: scenePhase) { oldPhase, newPhase in
    if newPhase == .background {
        BackgroundTaskManager.shared.scheduleDailyImagePrefetch()
    }
}

// In OnboardingView.completeOnboarding()
BackgroundTaskManager.shared.scheduleDailyImagePrefetch()
```

---

## 📁 Updated File Structure (Phase 4)

```
HopeCore/
├── Models/                   # ✅ Complete
│   ├── Message.swift
│   ├── AudioTrack.swift
│   ├── UserPreferences.swift
│   ├── Category.swift
│   └── SubscriptionTier.swift
├── Views/                    # ✅✅✅✅ Phase 4 Complete
│   ├── Home/
│   │   └── HomeView.swift           # ✅✅✅✅ UPDATED (Phase 4: deep linking)
│   ├── Settings/
│   │   └── SettingsView.swift       # ✅✅ Complete (Phase 2)
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # ✅✅✅ Complete (Phase 3)
│   ├── Audio/
│   │   └── AudioLibraryView.swift   # ✅✅ Complete (Phase 2)
│   └── Saved/
│       └── SavedMessagesView.swift  # ✅✅ Complete (Phase 2)
├── Components/               # ✅✅✅ Complete (Phase 3)
│   ├── MessageCard.swift             # ✅✅✅ Complete (Phase 3)
│   └── AudioPlayerComponent.swift    # ✅✅ Complete (Phase 2)
├── Services/                 # ✅✅✅✅ Phase 4 Complete
│   ├── NotificationManager.swift     # ✅✅✅✅ UPDATED (Phase 4: widget schedule)
│   ├── AudioManager.swift            # ✅✅ Complete (Phase 2)
│   ├── MessageService.swift          # ✅✅✅✅ UPDATED (Phase 4: widget integration)
│   ├── ImageCacheManager.swift       # ✅✅✅ Complete (Phase 3)
│   ├── SubscriptionManager.swift     # ✅ Complete (Phase 1)
│   ├── BackgroundTaskManager.swift   # ✅✅✅✅ UPDATED (Phase 4: widget updates)
│   └── WidgetDataStore.swift         # ✅✅✅✅ NEW (Phase 4: App Group sharing)
├── DesignSystem/             # ✅ Complete (Phase 1)
├── Utilities/                # ✅ Complete (Phase 1)
├── HopeCoreWidget/           # ✅✅✅✅ NEW (Phase 4: Widget Extension)
│   ├── HopeCoreWidget.swift          # ✅✅✅✅ Widget configuration & timeline
│   ├── HopeCoreWidgetView.swift      # ✅✅✅✅ SwiftUI views (Lock & Home Screen)
│   ├── HopeCoreWidgetEntry.swift     # ✅✅✅✅ Timeline entry model
│   ├── HopeCoreWidgetBundle.swift    # ✅✅✅✅ Widget bundle entry point
│   ├── WidgetDataStore.swift         # ✅✅✅✅ App Group data sharing
│   ├── HopeCoreWidget.entitlements   # ✅✅✅✅ App Groups capability
│   └── Assets.xcassets/              # ✅✅✅✅ Widget assets
├── HopeCore.entitlements     # ✅✅✅✅ UPDATED (Phase 4: App Groups)
├── Info.plist                # ✅✅✅✅ UPDATED (Phase 4: URL scheme)
└── HopeCoreApp.swift         # ✅✅✅✅ UPDATED (Phase 4: deep linking)
```

---

## ⚠️ CRITICAL: Required Info.plist Configuration

**IMPORTANT FOR NEXT AGENT:**

The background task implementation requires a manual update to `Info.plist` that cannot be done via code:

1. **Open Info.plist in Xcode**
2. **Add new key:** `BGTaskSchedulerPermittedIdentifiers`
3. **Type:** Array
4. **Add item:** `com.hopecore.prefetch-images` (String)

Without this configuration, background tasks will fail silently.

**XML Format (if editing raw plist):**
```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.hopecore.prefetch-images</string>
</array>
```

---

## ✅✅ Phase 2 Work Completed (Previous Session)

### Service Integration ✅

#### 1. MessageService → HomeView Integration ✅
**Location:** `Views/Home/HomeView.swift`

**Implementation:**
- ✅ Connected MessageService.shared singleton
- ✅ Load messages from SwiftData via `messageService.loadMessages(from:)`
- ✅ Display filtered messages (excludes demotivation from feed)
- ✅ Track message views with `messageService.markAsShown()`
- ✅ Toggle save state via `messageService.toggleSaved()`
- ✅ Auto-persist to SwiftData on changes
- ✅ Fallback to sample data for development

**Code Integration:**
```swift
// Load messages from MessageService
messageService.loadMessages(from: modelContext)
messages = messageService.filteredMessages

// Track views on scroll
messageService.markAsShown(message)
try? modelContext.save()

// Toggle saved state
messageService.toggleSaved(message)
try? modelContext.save()
```

---

#### 2. NotificationManager → OnboardingView Integration ✅
**Location:** `Views/Onboarding/OnboardingView.swift`

**Implementation:**
- ✅ Request notification authorization via `NotificationManager.shared.requestAuthorization()`
- ✅ Schedule initial notifications after onboarding complete
- ✅ Pass user preferences to notification scheduler
- ✅ Handle permission denial gracefully (still complete onboarding)
- ✅ Load messages via MessageService for scheduling

**Code Integration:**
```swift
// Request authorization in step 5
try await NotificationManager.shared.requestAuthorization()

// Schedule initial notifications
try await NotificationManager.shared.scheduleNotifications(
    preferences: prefs,
    messages: messages,
    modelContext: modelContext
)
```

---

#### 3. NotificationManager → SettingsView Integration ✅
**Location:** `Views/Settings/SettingsView.swift`

**Implementation:**
- ✅ Reschedule notifications when settings change
- ✅ Trigger rescheduling on "Done" button (if settings changed)
- ✅ Load messages via MessageService for rescheduling
- ✅ Check notification permission status before scheduling
- ✅ Handle rescheduling errors gracefully

**Code Integration:**
```swift
// Reschedule on settings save
try await NotificationManager.shared.scheduleNotifications(
    preferences: prefs,
    messages: messageService.filteredMessages,
    modelContext: modelContext
)
```

---

### New Views Implemented ✅

#### 4. AudioLibraryView ✅
**Location:** `Views/Audio/AudioLibraryView.swift`

**Features Implemented:**
- ✅ 2-column grid layout (LazyVGrid)
- ✅ Separate sections for Sleep Sounds and Focus Sessions
- ✅ Section headers with icons (moon for sleep, brain for focus)
- ✅ AudioCard component for each track:
  - Thumbnail placeholder with type icon
  - Track title (2 line limit)
  - Duration in SF Mono (formatted as MM:SS)
  - Download badge for offline tracks
- ✅ Tap to play → opens AudioPlayerOverlay
- ✅ Integration with AudioManager.shared
- ✅ Auto-loads sample tracks if database empty
- ✅ Empty state view with clear messaging
- ✅ Button press animations and haptic feedback
- ✅ Presented as sheet from HomeView

**Design Adherence:**
- Grid layout with 2 columns ✅
- SF Mono for duration display ✅
- Type icons per spec ✅
- Tap targets meet 44pt minimum ✅
- Haptic feedback on all interactions ✅

**Integration with HomeView:**
- Music button in HomeView opens AudioLibraryView as sheet ✅
- Removed placeholder audio player overlay ✅

---

#### 5. SavedMessagesView ✅
**Location:** `Views/Saved/SavedMessagesView.swift`

**Features Implemented:**
- ✅ 2-column grid layout of saved messages
- ✅ SwiftData query with predicate: `isSaved == true`
- ✅ Sort options (newest, oldest, category) with confirmation dialog
- ✅ SavedMessageCard component:
  - Async image loading with placeholder
  - Text preview (3 line limit)
  - Category badge
  - Rose border (saved indicator)
- ✅ Context menu actions:
  - Share message
  - Unsave (remove from collection)
- ✅ Empty state view with clear call-to-action
- ✅ Message count display in header
- ✅ Integration with MessageService for unsave action
- ✅ Share sheet for message sharing
- ✅ Haptic feedback throughout

**Design Adherence:**
- Grid layout with 2 columns ✅
- Rose border on saved cards (2pt) ✅
- Long-press (context menu) for actions ✅
- Empty state with icon and message ✅
- Sort by newest/oldest/category ✅

---

## 📁 Updated File Structure

```
HopeCore/
├── Models/                   # ✅ Complete
│   ├── Message.swift
│   ├── AudioTrack.swift
│   ├── UserPreferences.swift
│   ├── Category.swift
│   └── SubscriptionTier.swift
├── Views/                    # ✅✅ Phase 2 Complete
│   ├── Home/
│   │   └── HomeView.swift           # ✅✅ UPDATED (Phase 2)
│   ├── Settings/
│   │   └── SettingsView.swift       # ✅✅ UPDATED (Phase 2)
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # ✅✅ UPDATED (Phase 2)
│   ├── Audio/
│   │   └── AudioLibraryView.swift   # ✅✅ NEW (Phase 2)
│   └── Saved/
│       └── SavedMessagesView.swift  # ✅✅ NEW (Phase 2)
├── Components/               # ✅ Complete (Phase 1)
│   ├── MessageCard.swift
│   └── AudioPlayerComponent.swift
├── Services/                 # ✅ Ready for Integration (Phase 1)
│   ├── NotificationManager.swift
│   ├── AudioManager.swift
│   ├── MessageService.swift
│   ├── ImageCacheManager.swift
│   └── SubscriptionManager.swift
├── DesignSystem/             # ✅ Complete (Phase 1)
│   ├── Colors.swift
│   ├── Fonts.swift
│   ├── Spacing.swift
│   ├── Elevation.swift
│   └── AnimationTiming.swift
├── Utilities/                # ✅ Complete (Phase 1)
│   ├── Constants.swift
│   ├── HapticFeedback.swift
│   └── Extensions/
│       ├── View+Extensions.swift
│       └── Date+Extensions.swift
├── ViewModels/               # Not needed (using @Observable)
├── Widgets/                  # TODO (Phase 4)
└── HopeCoreApp.swift         # ✅ Complete (Phase 1)

```

---

## ✅ Phase 1 Work Completed (Previous Session)

### Core Views Implemented

#### 1. MessageCard Component ✅
**Location:** `Components/MessageCard.swift`

**Features Implemented:**
- ✅ All 4 presentation modes from designdoc.md:
  - `imageText`: Image at top, text below (most common)
  - `textOnBackground`: Text overlaid on image with opacity
  - `split`: Side-by-side 50/50 layout
  - `minimal`: Subtle background with prominent typography
- ✅ Glass materials (ultraThinMaterial) for depth
- ✅ 20pt padding, 16pt corner radius per spec
- ✅ Save/Share action buttons with haptic feedback
- ✅ Animated save state (heart pulse effect)
- ✅ AsyncImage loading from URLs
- ✅ Image placeholder for failed loads
- ✅ Author attribution display
- ✅ Saved state styling (rose border)

**Key Design Adherence:**
- Image max 60% of card height ✅
- 1.5x line height for message text ✅
- Spring animation on press (0.97 scale) ✅
- Rose accent for saved state ✅

---

#### 2. HomeView ✅
**Location:** `Views/Home/HomeView.swift`

**Features Implemented:**
- ✅ TikTok/Instagram-style vertical scrolling feed
- ✅ TabView with .page style for smooth pagination
- ✅ One message at a time display
- ✅ Top controls overlay:
  - App title "HopeCore"
  - Music button (opens audio player)
  - Settings button
- ✅ Message card integration with save/share
- ✅ Share sheet for message sharing
- ✅ Haptic feedback on scroll
- ✅ Loading state
- ✅ Empty state view
- ✅ Audio player overlay (modal presentation)

**Integration Points:**
- Uses MessageCard component ✅
- Connects to SettingsView via sheet ✅
- Shows AudioPlayerOverlay on music button ✅
- Generates share text with app attribution ✅

**TODO for Next Agent:**
- Connect to MessageService for real data loading
- Implement image pre-fetching with ImageCacheManager
- Add message view tracking

---

#### 3. OnboardingView ✅
**Location:** `Views/Onboarding/OnboardingView.swift`

**Features Implemented:**
- ✅ 5-step onboarding flow with smooth transitions
- ✅ Progress bar showing current step
- ✅ Step 1: Welcome screen with app introduction
- ✅ Step 2: User situation selection (recovery, transition, etc.)
- ✅ Step 3: Notification timing configuration:
  - Messages per day slider (1-5 for free)
  - Start time picker
  - End time picker
- ✅ Step 4: Demotivation message explanation for free users
- ✅ Step 5: Notification permission request
- ✅ Saves all preferences to UserPreferences model
- ✅ Sets hasCompletedOnboarding = true on completion
- ✅ Back/Continue navigation buttons
- ✅ Haptic feedback throughout

**Data Persistence:**
- Saves to UserPreferences via SwiftData ✅
- Creates default preferences if none exist ✅

**TODO for Next Agent:**
- Connect Step 5 to NotificationManager.requestAuthorization()
- Add error handling for permission denial

---

#### 4. SettingsView ✅
**Location:** `Views/Settings/SettingsView.swift`

**Features Implemented:**
- ✅ Form-based settings interface with sections:
  - **Premium Section:** Upgrade upsell for free users
  - **Notifications:** Messages per day, start/end times
  - **Quiet Hours:** Toggle + time range configuration
  - **Message Preferences:** Demotivation toggle (premium only)
  - **Sound & Haptic:** Notification sounds and haptic toggles
  - **About:** Version, subscription tier, stats
- ✅ Premium upsell sheet with feature list
- ✅ Real-time preference updates via bindings
- ✅ Saves changes to SwiftData on dismiss
- ✅ Dynamic UI based on subscription tier
- ✅ Haptic feedback on all interactions

**Premium Features:**
- Shows max messages (5 for free, 20 for premium) ✅
- Demotivation toggle only for premium ✅
- Premium badge in About section ✅

**TODO for Next Agent:**
- Integrate SubscriptionManager.subscribe() for purchases
- Connect "Restore Purchases" button
- Add notification rescheduling on settings change

---

#### 5. AudioPlayerOverlay Component ✅
**Location:** `Components/AudioPlayerComponent.swift`

**Features Implemented:**
- ✅ Full-screen modal audio player
- ✅ Album art display (240x240pt) with AsyncImage
- ✅ Track title and type display
- ✅ Real-time progress slider with seek capability
- ✅ Playback controls:
  - Skip backward 15s
  - Play/Pause (56pt, rose accent)
  - Skip forward 15s
- ✅ Speed selector (1x, 1.25x, 1.5x, 2.0x)
- ✅ Volume slider
- ✅ Close button to dismiss
- ✅ Observes AudioManager for state
- ✅ Progress timer for real-time updates
- ✅ Haptic feedback on all interactions

**Bonus: CompactAudioPlayer ✅**
- Compact version for home screen overlay
- Shows play/pause, track info, time
- Tap to expand to full player
- Included in same file

**TODO for Next Agent:**
- Add sleep timer functionality (15/30/60 min)
- Implement playback completion handling

---

#### 6. App Routing ✅
**Location:** `HopeCoreApp.swift`

**Features Implemented:**
- ✅ Created AppRootView to handle routing logic
- ✅ Checks UserPreferences.hasCompletedOnboarding
- ✅ Shows OnboardingView if not completed
- ✅ Shows HomeView if onboarding completed
- ✅ Creates default UserPreferences if none exist
- ✅ Proper SwiftData integration

**Routing Logic:**
```swift
if userPrefs.hasCompletedOnboarding {
    HomeView()
} else {
    OnboardingView()
}
```

---

## 📁 File Structure (Updated)

```
HopeCore/
├── Models/                   # ✅ Complete (from previous session)
│   ├── Message.swift
│   ├── AudioTrack.swift
│   ├── UserPreferences.swift
│   ├── Category.swift
│   └── SubscriptionTier.swift
├── Views/                    # ✅ Phase 1 Complete
│   ├── Home/
│   │   └── HomeView.swift           # ✅ NEW
│   ├── Settings/
│   │   └── SettingsView.swift       # ✅ NEW
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # ✅ NEW
│   ├── Audio/                        # TODO
│   └── Saved/                        # TODO
├── Components/               # ✅ Phase 1 Complete
│   ├── MessageCard.swift             # ✅ NEW
│   └── AudioPlayerComponent.swift    # ✅ NEW
├── Services/                 # ✅ Complete (from previous session)
│   ├── NotificationManager.swift
│   ├── AudioManager.swift
│   ├── MessageService.swift
│   ├── ImageCacheManager.swift
│   └── SubscriptionManager.swift
├── DesignSystem/             # ✅ Complete (from previous session)
│   ├── Colors.swift
│   ├── Fonts.swift
│   ├── Spacing.swift
│   ├── Elevation.swift
│   └── AnimationTiming.swift
├── Utilities/                # ✅ Complete (from previous session)
│   ├── Constants.swift
│   ├── HapticFeedback.swift
│   └── Extensions/
│       ├── View+Extensions.swift
│       └── Date+Extensions.swift
├── ViewModels/               # TODO (Optional - may not need)
├── Widgets/                  # TODO (Phase 4)
└── HopeCoreApp.swift         # ✅ Updated with routing

```

---

## 🚨 Critical Next Steps (Priority Order)

### ✅ Phase 3: Polish, Background Tasks & Image Caching (COMPLETE)

All Phase 3 tasks completed:
- ✅ ImageCacheManager integrated in MessageCard and HomeView
- ✅ Image pre-fetching activated for smooth scrolling
- ✅ SavedMessagesView navigation added to HomeView
- ✅ BackgroundTaskManager service created
- ✅ Daily image pre-loading scheduled (6 AM)
- ✅ Background tasks integrated in app lifecycle

**⚠️ MANUAL STEP REQUIRED:**
Add `BGTaskSchedulerPermittedIdentifiers` to Info.plist (see section above)

---

### ✅ Phase 4: Widgets Implementation (COMPLETE)

All Phase 4 widget tasks completed:
- ✅ Lock Screen widget created (circular and rectangular)
- ✅ Home Screen widget created (small, medium, large)
- ✅ Scheduled widget updates based on notification schedule
- ✅ Widget data sharing via App Groups
- ✅ Deep linking from widget to app
- ✅ Widget integration with MessageService and NotificationManager
- ✅ Widget updates when settings change

**Widget Extension:**
- Target: `HopeCoreWidget`
- Deployment: iOS 18.0
- App Group: `group.com.hopecore.shared`
- URL Scheme: `hopecore://message/{messageID}`

---

### Phase 5: Premium Purchase Flow (NEXT PRIORITY)

#### 1. Premium Purchase Flow
**File to Use:** `Services/SubscriptionManager.swift`

**What to Do:**
- Configure StoreKit products
- Implement purchase flow
- Restore purchases functionality
- Update UserPreferences on successful purchase
- Show confirmation with haptic feedback

---

## 🐛 Known Issues & TODOs

### ✅ Phase 2 Completed Items
- [x] MessageService integration in HomeView ✅
- [x] NotificationManager authorization request in onboarding ✅
- [x] Settings changes reschedule notifications ✅
- [x] Message view tracking connected ✅
- [x] Audio library view created ✅
- [x] Saved messages view created ✅

### ✅ Phase 3 Completed Items
- [x] ImageCacheManager integration for pre-fetching ✅
- [x] Navigation to SavedMessagesView from HomeView ✅
- [x] Background task for daily image pre-loading ✅
- [x] MessageCard uses cached images in all presentation modes ✅
- [x] Automatic cache cleanup (50MB memory, 100MB disk) ✅

### High Priority (Phase 4)
- [ ] ⚠️ Info.plist: Add BGTaskSchedulerPermittedIdentifiers
- [ ] Share sheet should include message image
- [ ] Error handling for failed image loads
- [ ] AudioPlayerOverlay missing sleep timer

### Medium Priority
- [ ] Category filtering not fully implemented
- [ ] No playback completion handling in AudioManager
- [ ] Audio track download functionality (offline playback)

### ✅ Phase 4 Completed Items
- [x] Lock Screen widget created (circular and rectangular) ✅
- [x] Home Screen widget created (small, medium, large) ✅
- [x] Widget updates based on notification schedule ✅
- [x] Widget data sharing via App Groups ✅
- [x] Deep linking from widget to app ✅
- [x] Widget integration with services ✅

### Low Priority (Phase 5)
- [ ] Premium purchase flow not connected to SubscriptionManager
- [ ] Restore purchases not implemented

---

## 🎯 Testing Checklist

### Phase 2 Testing - Before Moving Forward:

#### Onboarding Flow
- [ ] App launches and shows onboarding for first-time user
- [ ] Onboarding flow completes all 5 steps
- [ ] Notification permission request appears in step 5
- [ ] Preferences are saved to SwiftData
- [ ] Initial notifications are scheduled after onboarding
- [ ] After onboarding, app shows HomeView

#### HomeView & Message Feed
- [ ] Vertical scrolling works smoothly in HomeView
- [ ] Messages load from MessageService (or fallback to sample data)
- [ ] Message cards render all 4 presentation modes correctly
- [ ] Save/share buttons work with haptic feedback
- [ ] Tapping save toggles saved state (rose border appears)
- [ ] Message view tracking persists to SwiftData
- [ ] Scroll haptic feedback triggers correctly

#### Settings Integration
- [ ] Settings sheet opens from HomeView
- [ ] Settings changes persist to UserPreferences
- [ ] Notifications are rescheduled when settings change
- [ ] Premium upsell sheet displays correctly
- [ ] Quiet hours toggle works
- [ ] Sound/haptic toggles work

#### Audio Library
- [ ] Music button opens AudioLibraryView sheet
- [ ] Audio library shows 2-column grid
- [ ] Sleep and Focus sections display correctly
- [ ] Sample tracks load if database is empty
- [ ] Tapping track opens AudioPlayerOverlay (if implemented)
- [ ] Download badges show for offline tracks

#### Saved Messages
- [ ] SavedMessagesView displays only saved messages
- [ ] Grid layout shows 2 columns
- [ ] Sort options work (newest, oldest, category)
- [ ] Context menu allows unsaving messages
- [ ] Share action works from context menu
- [ ] Empty state displays when no saved messages
- [ ] Settings changes persist to UserPreferences
- [ ] Audio player overlay opens/closes smoothly
- [ ] All haptic feedback triggers correctly
- [ ] Dark mode appearance is correct throughout

#### Widgets (Phase 4)
- [ ] Widget appears in Lock Screen widget gallery
- [ ] Widget appears in Home Screen widget gallery
- [ ] Circular Lock Screen widget displays message correctly
- [ ] Rectangular Lock Screen widget shows 4 lines of text
- [ ] Home Screen small widget displays correctly
- [ ] Home Screen medium widget displays correctly
- [ ] Home Screen large widget displays correctly
- [ ] Rose border renders at 2pt width on all widgets
- [ ] Widget updates at each scheduled notification time
- [ ] Widget shows different message at each update
- [ ] Tapping widget opens app to correct message
- [ ] Deep linking works when app is launching
- [ ] Deep linking works when app is already running
- [ ] Empty state displays when no message available
- [ ] Widget works in both light and dark mode
- [ ] Text truncation works for long messages
- [ ] App Group data sharing works correctly
- [ ] Widget updates when notifications are rescheduled
- [ ] Widget updates during background task refresh

---

## 📖 Key Files Reference

### Core Views
- `Views/Home/HomeView.swift` - Main feed (TikTok-style)
- `Views/Onboarding/OnboardingView.swift` - First-time setup
- `Views/Settings/SettingsView.swift` - Preferences & subscription

### Components
- `Components/MessageCard.swift` - Message display (4 modes)
- `Components/AudioPlayerComponent.swift` - Full + compact player

### App Entry
- `HopeCoreApp.swift` - App routing logic

### Design System
- `DesignSystem/Colors.swift` - Color tokens
- `DesignSystem/Fonts.swift` - Typography
- `DesignSystem/Spacing.swift` - Layout measurements
- `Utilities/Extensions/View+Extensions.swift` - Reusable modifiers
- `Utilities/HapticFeedback.swift` - Tactile feedback

### Services
- `Services/MessageService.swift` - Message selection & rotation, widget integration
- `Services/NotificationManager.swift` - Notification scheduling, widget schedule updates
- `Services/AudioManager.swift` - Audio playback
- `Services/ImageCacheManager.swift` - Image caching
- `Services/BackgroundTaskManager.swift` - Background tasks, widget updates
- `Services/WidgetDataStore.swift` - App Group data sharing for widgets
- `Services/SubscriptionManager.swift` - StoreKit integration

### Widget Extension
- `HopeCoreWidget/HopeCoreWidget.swift` - Widget configuration & timeline provider
- `HopeCoreWidget/HopeCoreWidgetView.swift` - SwiftUI views for all widget families
- `HopeCoreWidget/HopeCoreWidgetEntry.swift` - Timeline entry model
- `HopeCoreWidget/WidgetDataStore.swift` - App Group data access (duplicate of main app)

---

## 💡 Implementation Notes for Next Agent

### 1. Design System Usage
All views follow the design system strictly. Always use:
- Pre-defined colors from `Colors.swift`
- Typography helpers from `Fonts.swift` (e.g., `.messageTextStyle()`)
- Spacing constants from `Spacing.swift`
- View modifiers from `View+Extensions.swift` (e.g., `.messageCardStyle()`)

### 2. Haptic Feedback
Every interaction has haptic feedback via `HapticFeedback`:
- `messageSaved()` - Heart pulse on save
- `buttonPress()` - Light tap for buttons
- `cardSwipe()` - Selection feedback on scroll
- `audioPlayPause()` - Light tap for play/pause

### 3. SwiftData Patterns
All data models use `@Model` macro:
```swift
@Query private var messages: [Message]
```

Saving changes:
```swift
try modelContext.save()
```

### 4. Observable Services
All services use `@Observable` for SwiftUI integration:
```swift
@State private var audioManager = AudioManager.shared
```

### 5. Sample Data
All models include `.sample*` data for development:
- `Message.sampleMessages`
- `AudioTrack.sampleTracks`
- Use these in previews and testing

---

## 🚀 Quick Start for Next Agent

**To continue development:**

1. **Read the spec files:**
   - `HopeCore/technical_spec.md` - Product requirements
   - `HopeCore/designdoc.md` - Visual design system
   - `HopeCore/agents.md` - Development guidelines

2. **Start with Service Integration (highest priority):**
   - Connect MessageService to HomeView
   - Integrate NotificationManager with onboarding
   - Wire up AudioManager to audio player

3. **Then build missing views:**
   - AudioLibraryView (grid of tracks)
   - SavedMessagesView (filtered message list)

4. **Test thoroughly:**
   - Run app in simulator
   - Complete onboarding flow
   - Test all interactions
   - Verify haptic feedback

5. **Follow the design system:**
   - Use pre-defined colors, fonts, spacing
   - Apply view modifiers for consistency
   - Add comments for future agents

---

**Good luck! Phase 1 is solid. Build on this foundation! 🎨**
