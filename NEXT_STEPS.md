# HopeCore App - Next Steps for Future Agents

## Overview

This document outlines the work completed and the critical next steps for future development agents. HopeCore is an iOS app built with SwiftUI and SwiftData, designed to deliver hopecore messages and audio content to users rebuilding their lives.

**Created:** November 10, 2025
**Last Updated:** November 10, 2025 (Phase 1 Complete)
**Session:** Phase 1 Core Views Implementation
**Status:** ✅ Core Views Complete - Ready for Integration & Testing

---

## ✅ Phase 1 Work Completed (Current Session)

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

### Phase 2: Service Integration & Data (HIGH PRIORITY)

#### 1. Connect MessageService to HomeView
**File to Modify:** `Views/Home/HomeView.swift`

**What to Do:**
- Replace sample messages with MessageService.getTodaysMessages()
- Implement messageService.markAsShown() on scroll
- Add image pre-fetching via ImageCacheManager
- Handle empty states when no messages available

**Code Snippet:**
```swift
// In HomeView.loadMessages()
Task {
    messages = await messageService.getTodaysMessages()
    isLoading = false
}

// In handleIndexChange()
messageService.markAsShown(messages[newValue])
```

---

#### 2. Connect NotificationManager to Settings & Onboarding
**Files to Modify:**
- `Views/Settings/SettingsView.swift`
- `Views/Onboarding/OnboardingView.swift`

**What to Do:**
- Request notification authorization in OnboardingView step 5
- Reschedule notifications when settings change in SettingsView
- Handle permission denied states

**Code Snippet:**
```swift
// In OnboardingView.requestNotificationPermission()
NotificationManager.shared.requestAuthorization { granted in
    isComplete = true
}

// In SettingsView.saveSettings()
NotificationManager.shared.scheduleNotifications()
```

---

#### 3. Implement Audio Library View
**File to Create:** `Views/Audio/AudioLibraryView.swift`

**What to Build:**
- 2-column grid of audio tracks
- Separate sections for Sleep and Focus
- Show duration and download status
- Tap to play (loads AudioPlayerOverlay)
- Integration with AudioManager

**Design Specs:**
- Grid layout with 2 columns
- AudioCard component for each track
- Show duration with SF Mono font
- Icon for type (moon for sleep, brain for focus)

---

#### 4. Implement Saved Messages View
**File to Create:** `Views/Saved/SavedMessagesView.swift`

**What to Build:**
- Grid view of saved messages (isSaved = true)
- Sort options: newest, oldest, category
- Long-press to unsave
- Empty state if no saved messages
- Uses MessageCard component

**Query Example:**
```swift
@Query(filter: #Predicate<Message> { $0.isSaved == true })
private var savedMessages: [Message]
```

---

### Phase 3: Background Tasks & Notifications (MEDIUM PRIORITY)

#### 1. Daily Image Pre-loading
**File to Modify:** `Services/ImageCacheManager.swift` + Create background task

**What to Do:**
- Schedule background task to run each morning
- Pre-load 3 random message images per spec
- Respect cache limits (50MB memory, 100MB disk)
- Clean up old cache automatically

---

#### 2. Notification Scheduling
**File to Use:** `Services/NotificationManager.swift`

**What to Do:**
- Schedule daily notifications based on UserPreferences
- Distribute evenly between start/end times
- Include message text and image attachments
- Respect quiet hours
- Handle demotivation pattern (1 per 5 for free users)

**Logic:**
```swift
// Free user with 5 messages/day
// If demotivationCounter >= 5, send demotivation message
// Otherwise send regular message
```

---

### Phase 4: Widgets & Advanced Features (LOW PRIORITY)

#### 1. Lock Screen Widget
**Directory:** `Widgets/`

**What to Build:**
- Small widget showing daily message
- Update once daily for free users
- Update on schedule for premium users
- Rose border (2pt) per design
- Tapping opens app to that message

---

#### 2. Premium Purchase Flow
**File to Use:** `Services/SubscriptionManager.swift`

**What to Do:**
- Configure StoreKit products
- Implement purchase flow
- Restore purchases functionality
- Update UserPreferences on successful purchase
- Show confirmation with haptic feedback

---

## 🐛 Known Issues & TODOs

### High Priority
- [ ] MessageService integration in HomeView (using sample data currently)
- [ ] NotificationManager authorization request (placeholder in onboarding)
- [ ] Settings changes don't reschedule notifications yet
- [ ] Image pre-fetching not implemented in HomeView
- [ ] Message view tracking not connected
- [ ] Audio player doesn't load real tracks yet (AudioManager not connected)

### Medium Priority
- [ ] Audio library view not created
- [ ] Saved messages view not created
- [ ] Background task for image pre-loading not set up
- [ ] Widget code not created
- [ ] Share sheet doesn't include message image
- [ ] No error handling for failed image loads

### Low Priority
- [ ] AudioPlayerOverlay missing sleep timer
- [ ] No playback completion handling
- [ ] Category filtering not implemented
- [ ] Premium purchase flow not connected
- [ ] Restore purchases not implemented

---

## 🎯 Testing Checklist

### Before Moving Forward, Test:
- [ ] App launches and shows onboarding for first-time user
- [ ] Onboarding flow completes and saves preferences
- [ ] After onboarding, app shows HomeView
- [ ] Vertical scrolling works smoothly in HomeView
- [ ] Message cards render all 4 presentation modes correctly
- [ ] Save/share buttons work with haptic feedback
- [ ] Settings sheet opens from HomeView
- [ ] Settings changes persist to UserPreferences
- [ ] Audio player overlay opens/closes smoothly
- [ ] All haptic feedback triggers correctly
- [ ] Dark mode appearance is correct throughout

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

### Services (Ready for Integration)
- `Services/MessageService.swift` - Message selection & rotation
- `Services/NotificationManager.swift` - Notification scheduling
- `Services/AudioManager.swift` - Audio playback
- `Services/ImageCacheManager.swift` - Image caching
- `Services/SubscriptionManager.swift` - StoreKit integration

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
