# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HopeCore is a native iOS app (Swift/SwiftUI) delivering hopecore messages throughout the day with curated sleep and focus audio. It uses SwiftData for persistence, WidgetKit for lock screen and home screen widgets, and images hosted on Cloudflare R2.

- **Platform:** iOS 18.0+
- **Architecture:** MVVM with Services Layer
- **No external dependencies** - pure Apple frameworks (SwiftUI, SwiftData, WidgetKit, AVFoundation)

## Build Commands

```bash
# Build for simulator
xcodebuild -project HopeCore.xcodeproj -scheme HopeCore -configuration Debug -destination 'generic/platform=iOS Simulator' build

# Build release
xcodebuild -project HopeCore.xcodeproj -scheme HopeCore -configuration Release

# Archive for distribution
xcodebuild -project HopeCore.xcodeproj -scheme HopeCore -configuration Release -archivePath "build/HopeCore.xcarchive" archive
```

No tests are currently implemented.

## Architecture

### Main App (`/HopeCore/`)
- **Entry:** `HopeCoreApp.swift` - SwiftData setup, deep linking (`hopecore://message/{id}`)
- **Services Layer:** Core business logic
  - `MessageService.swift` - Message loading, filtering, rotation
  - `NotificationManager.swift` - Local notification scheduling
  - `ImageCacheManager.swift` - Image downloading/caching from R2
  - `WidgetDataStore.swift` - App Groups data sharing (`group.com.hopecore.shared`)
  - `BackgroundTaskManager.swift` - Pre-loads 3 images daily
- **Views:** `HomeView.swift` (TikTok-style feed), `AudioLibraryView.swift`, `SavedMessagesView.swift`, `SettingsView.swift`
- **DesignSystem:** Centralized tokens in `Colors.swift`, `Spacing.swift`, `Fonts.swift`

### Widget Extension (`/HopeCoreWidget/`)
- `HopeCoreWidget.swift` - Timeline provider for lock screen (circular, rectangular) and home screen (small, medium, large)
- Shares data with app via `WidgetDataStore.swift` using App Groups

### Data Flow
- Messages loaded from bundled `quotes.json` → SwiftData
- Images served from `https://pub-0017d537075f47dba685fa2a8ebf5591.r2.dev/`
- Two presentation modes: `imageCard` (full-screen with baked-in text) or `textOverlayBackground` (text overlaid on imagery)

## Key Patterns

- **Subscription tiers:** Free (5 msgs/day + demotivation msgs) vs Premium (20/day, optional demotivation)
- **Widget updates:** Timeline entries match notification schedule; free users get single 6 AM update
- **Image caching:** Pre-download and cache locally for offline availability
- **Deep linking:** `hopecore://message/{messageID}` - widget taps navigate to specific messages

## Starting Points

- **UI changes:** `Views/Home/HomeView.swift`, `Components/MessageCard.swift`
- **Data/messages:** `Services/MessageService.swift`, `Models/Message.swift`
- **Widgets:** `HopeCoreWidget/HopeCoreWidget.swift`
- **Notifications:** `Services/NotificationManager.swift`
- **Roadmap:** `NEXT_STEPS.md` (phase tracking and TODOs)
