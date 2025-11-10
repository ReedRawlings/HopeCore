# HopeCore App - Next Steps for Future Agents

## Overview

This document outlines the work completed in this session and the critical next steps for future development agents. HopeCore is an iOS app built with SwiftUI and SwiftData, designed to deliver hopecore messages and audio content to users rebuilding their lives.

**Created:** November 10, 2025
**Session:** App Foundation Initialization
**Status:** Foundation Complete - Ready for View Implementation

---

## ✅ Work Completed

### 1. Folder Structure

The following directory structure has been established:

```
HopeCore/
├── Models/              # SwiftData models for persistent storage
├── Views/               # SwiftUI view files (placeholder structure created)
│   ├── Home/
│   ├── Settings/
│   ├── Audio/
│   ├── Onboarding/
│   └── Saved/
├── Components/          # Reusable UI components
├── ViewModels/          # MVVM view models
├── Services/            # Business logic and service managers
├── DesignSystem/        # Design tokens and styling
├── Utilities/           # Helper functions and extensions
│   └── Extensions/
└── Widgets/             # iOS widgets
```

### 2. Design System (✅ Complete)

All design system files follow specifications from `designdoc.md`:

**Files Created:**
- `DesignSystem/Colors.swift` - Complete color palette (rose/magenta primary, emerald secondary, dark backgrounds)
- `DesignSystem/Fonts.swift` - Typography system (SF Pro Display/Text/Rounded/Mono)
- `DesignSystem/Spacing.swift` - 4pt grid-based spacing system
- `DesignSystem/Elevation.swift` - Material/glass depth strategy (NO shadows)
- `DesignSystem/AnimationTiming.swift` - Animation curves and timings

**Key Design Principles Implemented:**
- Rose/magenta (#EC4899) as primary accent for hopecore messaging
- Emerald (#10B981) for progress and growth indicators
- Dark backgrounds (#0A0E14) with glass materials for cards
- NO custom shadows - only native iOS blur materials
- 1.5x line height for message text readability
- Haptic feedback for all interactions

### 3. Data Models (✅ Complete)

All SwiftData models created and integrated:

**Files Created:**
- `Models/Message.swift` - Hopecore message model with image URLs, categories, presentation modes
- `Models/AudioTrack.swift` - Audio content (sleep sounds, focus sessions)
- `Models/UserPreferences.swift` - User settings, subscription, notification preferences
- `Models/Category.swift` - Message categories (Resilience, Agency, Rebuilding, Possibility, Demotivation)
- `Models/SubscriptionTier.swift` - Free vs Premium tier features and pricing

**Key Data Structures:**
- Messages support 4 presentation modes: imageText, textOnBackground, split, minimal
- Free users: max 5 messages/day, 1 demotivation per 5 messages (mandatory)
- Premium users: up to 20 messages/day, demotivation optional
- All models include sample data for development

### 4. Service Managers (✅ Complete)

Core business logic services created:

**Files Created:**
- `Services/NotificationManager.swift` - Local notification scheduling, respects quiet hours, handles demotivation pattern
- `Services/AudioManager.swift` - Audio playback (streaming + offline), background playback, playback controls
- `Services/ImageCacheManager.swift` - R2 Cloudflare image downloading, memory + disk caching, daily pre-loading
- `Services/MessageService.swift` - Message selection algorithm, rotation logic, saved messages
- `Services/SubscriptionManager.swift` - StoreKit integration, free vs premium logic, purchase flow

**Key Features:**
- All services are Observable singletons
- Notification scheduling with smart time distribution
- Image pre-loading (3 random images daily per spec)
- Message rotation to avoid repetition
- Audio supports 1.0x, 1.25x, 1.5x, 2.0x playback rates

### 5. Utilities (✅ Complete)

Helper functions and extensions:

**Files Created:**
- `Utilities/Constants.swift` - App-wide configuration (R2 URLs, limits, defaults)
- `Utilities/HapticFeedback.swift` - Tactile feedback system (light, medium, success patterns)
- `Utilities/Extensions/View+Extensions.swift` - SwiftUI view modifiers and styling helpers
- `Utilities/Extensions/Date+Extensions.swift` - Date formatting, relative time, notification helpers

**Key Utilities:**
- Pre-defined haptic patterns for all interactions (messageSaved, audioPlayPause, etc.)
- Card styling modifiers (messageCardStyle, primaryButtonStyle, etc.)
- Date formatters (relativeTimeString, timeString, etc.)
- Conditional modifiers and loading states

### 6. App Configuration (✅ Complete)

**Files Updated:**
- `HopeCoreApp.swift` - SwiftData container configured with all models, services initialized, global appearance configured

---

## 🚨 Critical Next Steps

### Phase 1: Core Views (PRIORITY 1)

These views are essential for MVP functionality:

#### 1. HomeView (Views/Home/HomeView.swift)
**Purpose:** Main app screen with vertical scrolling message feed

**Requirements from technical_spec.md:**
- Vertical scroll like Instagram/TikTok (one message at a time)
- Overlay for favorite/share buttons
- Music icon to open audio overlay
- Settings icon (top right)

**Implementation Notes:**
```swift
// Use TabView with .page style for TikTok-like scroll
// Load 3 messages at a time (current, previous, next)
// Pre-fetch images using ImageCacheManager
// Haptic feedback on scroll (HapticFeedback.cardSwipe())
// Track message views with MessageService.markAsShown()
```

**Key Components Needed:**
- Message card with overlay controls
- Audio player overlay (modal sheet)
- Share sheet integration

#### 2. OnboardingView (Views/Onboarding/OnboardingView.swift)
**Purpose:** First-time user setup flow

**Requirements from technical_spec.md:**
- Brief questions about user's situation
- Areas of life being rebuilt
- Notification timing preferences
- Demotivation message explanation for free users
- Request notification permissions

**Implementation Notes:**
```swift
// 3-4 screens with smooth transitions
// Save to UserPreferences on completion
// Request NotificationManager.requestAuthorization()
// Set hasCompletedOnboarding = true
```

#### 3. SettingsView (Views/Settings/SettingsView.swift)
**Purpose:** User preferences and subscription management

**Requirements from technical_spec.md:**
- Notification settings (frequency, timing, quiet hours)
- Premium subscription upsell
- Toggle demotivation messages (premium only)
- Sound/haptic preferences

**Implementation Notes:**
```swift
// Use Form with sections
// Link to SubscriptionManager for premium flow
// Update UserPreferences on changes
// Reschedule notifications when settings change
```

### Phase 2: Essential Components (PRIORITY 1)

#### 1. MessageCard (Components/MessageCard.swift)
**Purpose:** Display message with image-text pairing

**Design Requirements from designdoc.md:**
- Glass background (ultraThinMaterial)
- 20pt padding, 16pt corner radius
- Support 4 presentation modes
- Image max 60% of card height
- 1.5x line height for text
- Save/Share buttons at bottom

**Implementation Notes:**
```swift
// Switch on presentationMode
// Use AsyncImageView from ImageCacheManager
// Animate save state (heart pulse)
// Handle tap for full-screen view
```

#### 2. AudioPlayerOverlay (Components/AudioPlayerComponent.swift)
**Purpose:** Modal audio player with controls

**Design Requirements from designdoc.md:**
- Full-screen modal presentation
- 240x240pt album art
- Progress slider with time labels
- Play/Pause (56pt button, rose accent)
- Speed selector (1x, 1.25x, 1.5x)
- Volume slider

**Implementation Notes:**
```swift
// Observe AudioManager for state
// Update progress in real-time
// Haptic on play/pause
// Gesture to dismiss
```

### Phase 3: Audio & Saved Messages (PRIORITY 2)

#### 1. AudioLibraryView (Views/Audio/AudioLibraryView.swift)
- 2-column grid of audio cards
- Separate sections for Sleep and Focus
- Show duration and download status (premium)

#### 2. SavedMessagesView (Views/Saved/SavedMessagesView.swift)
- Grid view of saved messages
- Sort by newest/oldest/category
- Long-press to unsave

### Phase 4: Advanced Features (PRIORITY 3)

#### 1. Widgets
- Lock screen widget (daily message)
- Home screen widget (message + audio shortcuts)
- Configure in `Widgets/` directory

#### 2. Background Tasks
- Daily image pre-loading (3 images at morning notification time)
- Message rotation at midnight
- Cache cleanup when app launches

#### 3. Premium Flow
- Subscription paywall UI
- StoreKit product display
- Restore purchases flow

---

## 📋 Implementation Checklist

Use this checklist for tracking progress:

### Views
- [ ] HomeView with vertical scroll
- [ ] OnboardingView with multi-step flow
- [ ] SettingsView with notification preferences
- [ ] AudioLibraryView with grid layout
- [ ] SavedMessagesView with filtering
- [ ] Full-screen MessageDetailView

### Components
- [ ] MessageCard with 4 presentation modes
- [ ] AudioPlayerOverlay with full controls
- [ ] CategoryFilterView for browse
- [ ] ActionButtons (Save, Share)
- [ ] AudioCard for library

### ViewModels
- [ ] HomeViewModel (message feed logic)
- [ ] SettingsViewModel (preferences binding)
- [ ] AudioViewModel (playback state)
- [ ] SavedMessagesViewModel (filtering/sorting)

### Integration
- [ ] Wire OnboardingView to app entry point
- [ ] Connect NotificationManager to SettingsView
- [ ] Implement share sheet for messages
- [ ] Add background audio session handling
- [ ] Configure widgets with WidgetKit

### Testing & Polish
- [ ] Test notification scheduling
- [ ] Verify image caching works
- [ ] Test audio playback (foreground + background)
- [ ] Ensure haptic feedback works throughout
- [ ] Test free vs premium flows
- [ ] Verify demotivation pattern (1 per 5 for free)

---

## 🎯 Key Design Decisions

### Message Presentation Modes

Per `designdoc.md`, there are 4 modes:

1. **imageText** (most common): Image at top, text below with 16pt gap
2. **textOnBackground**: Text overlaid on image (opacity 0.4)
3. **split**: Side-by-side layout (50/50)
4. **minimal**: Subtle background with prominent typography

Implement all 4 in MessageCard component with switch statement.

### Notification Strategy

Per `technical_spec.md`:

**Free Users:**
- Max 5 messages/day
- Evenly distributed between start/end time
- Every 5th message is demotivation (mandatory)
- Widget updates once daily

**Premium Users:**
- Up to 20 messages/day
- Category filtering available
- Demotivation disabled by default (can enable)
- Widget updates match notification schedule

**Implementation:**
- Use `NotificationManager.scheduleNotifications()` daily at midnight
- Respect quiet hours
- Include image attachments in notifications

### Image Caching Strategy

Per `technical_spec.md`:

- Images hosted on R2 Cloudflare
- Pre-load 3 random images each morning
- Memory cache (50MB limit) + disk cache (100MB limit)
- Automatic cleanup at 80% threshold

**Implementation:**
- Call `ImageCacheManager.preloadDailyImages()` at morning notification time
- Use `AsyncImageView` in all message cards
- Background task for cache cleanup

### Audio Playback

Per `technical_spec.md`:

**Sleep Sounds:** 10-15 min tracks
**Focus Sessions:** 5-30 min tracks

**Features:**
- Offline playback (premium users can download)
- Background audio (continues when app backgrounded)
- Playback rates: 1.0x, 1.25x, 1.5x, 2.0x
- Volume control
- Progress slider

**Implementation:**
- AudioManager handles all playback
- Configure audio session for background in HopeCoreApp
- Show now-playing controls in lock screen

---

## 🔧 Technical Considerations

### SwiftData Best Practices

1. **Fetching Messages:**
```swift
let descriptor = FetchDescriptor<Message>(
    predicate: #Predicate { !$0.isDemotivation },
    sortBy: [SortDescriptor(\.lastShownAt)]
)
let messages = try modelContext.fetch(descriptor)
```

2. **Updating User Preferences:**
```swift
// UserPreferences should be a singleton instance
let descriptor = FetchDescriptor<UserPreferences>()
let prefs = try modelContext.fetch(descriptor).first ?? UserPreferences()
prefs.messagesPerDay = 5
try modelContext.save()
```

### R2 Cloudflare Integration

Currently using placeholder URLs in `Constants.swift`:

```swift
static let imageBaseURL = "https://r2.example.com/images"
static let audioBaseURL = "https://r2.example.com/audio"
```

**AGENT NOTE:** Update these with actual R2 bucket URLs when available.

**URL Format:**
- Images: `{imageBaseURL}/{messageId}.jpg`
- Audio: `{audioBaseURL}/{trackId}.mp3`

### App Store Connect Configuration

**Required Setup:**
1. Configure In-App Purchase products:
   - `com.hopecore.premium.monthly`
   - `com.hopecore.premium.yearly`
   - `com.hopecore.premium.lifetime`

2. Set up App Groups (for widgets):
   - `group.com.hopecore.shared`

3. Configure Background Modes:
   - Audio, AirPlay, and Picture in Picture
   - Background fetch (for daily tasks)

---

## 🐛 Known Issues / TODOs

### High Priority
1. ContentView is still the default placeholder - needs replacement with proper routing
2. No onboarding check - app shows ContentView for all users
3. Sample data is hardcoded - needs backend integration
4. R2 URLs are placeholders - need actual Cloudflare configuration
5. StoreKit products not configured - premium flow won't work

### Medium Priority
1. Background task scheduling not implemented
2. Widget code not created
3. Push notification images not attached
4. Audio download progress tracking missing
5. Category filtering logic incomplete

### Low Priority
1. Analytics/telemetry not implemented
2. Error handling could be more robust
3. Offline mode handling incomplete
4. Share sheet customization needed
5. Accessibility labels missing

---

## 📖 Reference Documentation

**Critical Files to Review:**
- `HopeCore/technical_spec.md` - Product requirements and features
- `HopeCore/designdoc.md` - Visual design system and UI specifications
- `HopeCore/agents.md` - Development guidelines for agents

**Design System Files:**
- `DesignSystem/Colors.swift` - All color tokens
- `DesignSystem/Fonts.swift` - Typography scale
- `DesignSystem/Spacing.swift` - Layout measurements
- `DesignSystem/AnimationTiming.swift` - Animation specs

**Key Services:**
- `Services/NotificationManager.swift` - Notification logic
- `Services/AudioManager.swift` - Audio playback
- `Services/MessageService.swift` - Message selection
- `Services/ImageCacheManager.swift` - Image handling

---

## 💡 Development Tips for Future Agents

1. **Always comment for agents:** Leave detailed comments explaining design decisions, especially for complex business logic.

2. **Follow the design system:** Use pre-defined modifiers from `View+Extensions.swift` rather than inline styling.

3. **Test with sample data:** All models include `.sampleMessages`, `.sampleTracks`, etc. for previews.

4. **Respect the specs:** Don't add features not in `technical_spec.md` without human approval.

5. **Use haptic feedback:** Call appropriate `HapticFeedback` methods for all interactions.

6. **Observable pattern:** All services use `@Observable` for SwiftUI integration.

7. **Async/await:** Services use modern concurrency - always mark functions as `async` when needed.

8. **Error handling:** Use proper do-catch blocks and display user-friendly errors.

---

## 🚀 Getting Started for Next Agent

**Immediate next steps:**

1. **Read all three spec documents:**
   - `technical_spec.md`
   - `designdoc.md`
   - `agents.md`

2. **Start with HomeView:**
   - Create vertical scrolling message feed
   - Implement TikTok-like pagination
   - Add overlay controls
   - Test with sample messages

3. **Then OnboardingView:**
   - Multi-step flow
   - Save preferences
   - Request permissions
   - Set completion flag

4. **Finally, wire up routing in HopeCoreApp:**
```swift
var body: some Scene {
    WindowGroup {
        if userPreferences.hasCompletedOnboarding {
            HomeView()
        } else {
            OnboardingView()
        }
    }
    .modelContainer(sharedModelContainer)
}
```

**Good luck! The foundation is solid. Build amazing views! 🎨**
