# Hopecore App - Design System

## Design Philosophy

### Core Principles

1. **Message-First Design** - Every interaction centers the hopecore message and its paired imagery or background
2. **Visual Resonance** - Image-text pairings are intentional; imagery amplifies emotional impact
3. **Accessibility Through Simplicity** - Minimal UI chrome; notifications and cards do the heavy lifting

### Design Intent

Hopecore is a companion for people rebuilding their lives. The app should feel:
- **Hopeful** - Possibility-focused, not motivational platitude
- **Visceral** - Images matter; they're not decoration
- **Spacious** - Time in-app is brief; messages are portable
- **Grounded** - Real language, authentic imagery, no corporate tone
- **Capable** - Serious and effective, emotionally intelligent
- **Restorative** - Audio complements messages for holistic moments

---

## 🎨 Color System

*Adapted from NoGoon with warmer, more hopeful accents*

### Base Palette

```swift
struct BackgroundColors {
    // Screen backgrounds
    static let primary = UIColor(hex: "#0A0E14")      // Main backgrounds
    static let secondary = UIColor(hex: "#0F1419")    // Nested backgrounds, modals
    
    // Material backgrounds (glassmorphism)
    static let ultraThin = UIBlurEffect.Style.systemUltraThinMaterialDark
    static let regular = UIBlurEffect.Style.systemMaterialDark
    
    // Solid backgrounds
    static let tertiary = UIColor(hex: "#1C2128")     // Text input fields
    static let elevated = UIColor(hex: "#161B22")     // Chat/cards
}

struct AccentColors {
    // Primary (Hopecore State)
    static let primary = UIColor(hex: "#EC4899")      // Rose/magenta - warmth, possibility
    static let primaryLight = UIColor(hex: "#F472B6") // Lighter rose for highlights
    static let primaryDark = UIColor(hex: "#BE185D")  // Darker rose for depth
    
    // Secondary (Supportive)
    static let secondary = UIColor(hex: "#10B981")    // Emerald - growth, resilience
    static let secondaryLight = UIColor(hex: "#34D399")
    
    // Semantic
    static let success = UIColor(hex: "#10B981")      // Progress (emerald)
    static let warmth = UIColor(hex: "#F59E0B")       // Amber - inspiring moments
    static let neutral = UIColor(hex: "#6B7280")      // Gray - neutral info
}

struct TextColors {
    static let primary = UIColor(hex: "#FFFFFF")      // Main content
    static let secondary = UIColor(hex: "#9CA3AF")    // Supporting text
    static let tertiary = UIColor(hex: "#6B7280")     // Labels, metadata
    static let inverse = UIColor(hex: "#0A0E14")      // Text on bright backgrounds
    static let hopeful = UIColor(hex: "#EC4899")      // Hopecore messaging
    static let success = UIColor(hex: "#10B981")      // Achievement
}
```

### Color Usage Rules

**Rose/Magenta (Primary):**
- Hopecore messages and highlights
- Primary CTAs (Save Message, Share)
- Active states for favorites
- Message card borders
- Inspirational data points

**Emerald (Secondary/Progress):**
- Streak indicators
- Focus session completion
- Sleep quality markers
- Secondary actions

**Amber (Warmth):**
- Milestone celebrations
- Audio now playing
- Meaningful moments

**Gray (Neutral):**
- Metadata and timestamps
- Disabled states
- Supporting information

---

## 📝 Typography System

*Same as NoGoon, with hopecore-specific applications*

```swift
struct AppFonts {
    static let display = "SF Pro Display"     // Large titles
    static let text = "SF Pro Text"          // Body, UI
    static let rounded = "SF Pro Rounded"    // Buttons, friendly
    static let mono = "SF Mono"              // Numeric data
}
```

### Type Scale (Same as NoGoon)

**Display:** 28pt (screen titles, hero messages)
**Title:** 22pt (section headers)
**Subtitle:** 18pt (card headers)
**Large Body:** 17pt (primary content, message text)
**Regular Body:** 15pt (supporting text)
**Small Body:** 13pt (metadata, timestamps)
**Caption:** 11pt (fine print, labels)

### Hopecore-Specific Usage

- **Message Text:** SF Pro Text, 17pt, 1.5x line height (readability)
- **Inspirational Quotes:** SF Pro Display, 22pt, center-aligned
- **Audio Session Names:** SF Pro Text, 15pt, secondary color
- **Timestamps:** SF Mono, 13pt, tertiary color

---

## 📏 Spacing System

*Identical to NoGoon: 4pt grid base*

```swift
struct Spacing {
    static let xs: CGFloat = 8      // Related elements
    static let sm: CGFloat = 12     // Card internal spacing
    static let md: CGFloat = 16     // Section spacing
    static let lg: CGFloat = 20     // Screen margins
    static let xl: CGFloat = 24     // Major sections
    static let xxl: CGFloat = 32    // Screen-level separation
    static let xxxl: CGFloat = 48   // Hero spacing
}
```

**Screen Margins:** 20pt horizontal, 20pt top/24pt bottom
**Card Padding:** 16-20pt (generous breathing room)
**Message Cards:** 24pt vertical padding (emphasis)
**Audio Component:** 16pt padding with clear visual separation

---

## 🖼️ Component Library

### Message Card (Hero Component)

```swift
// Primary focus: Image-text pairing

// Container
background: Glass (.ultraThinMaterial)
cornerRadius: 16pt
padding: 20pt
aspectRatio: Varies (portrait/square default)

// Image Section (top)
image:
  size: 100% width, auto height (constrained to 60% max)
  cornerRadius: 12pt
  contentMode: .aspectFill
  backgroundColor: secondary (placeholder)

// Text Section (bottom)
spacing: 16pt gap between image and text
textColor: TextColors.primary
font: SF Pro Text, 17pt, 1.5x line height

// Interactive States
pressed: scale(0.97) + brightness(0.9)
saved: border 2pt rose with filled heart icon
animation: 0.2s spring

// Actions (bottom of card)
layout: Horizontal, 12pt gap
- Share (SF Pro Rounded, 15pt)
- Save (SF Pro Rounded, 15pt)
```

### Minimal Card (Text-on-Background)

```swift
// Secondary presentation: Text-heavy message

background: Glass (.ultraThinMaterial)
cornerRadius: 16pt
padding: 20pt
minHeight: 160pt

// Background Image (subtle)
backgroundImage: Opacity 0.3, blur 10pt
blendMode: multiply

// Text Content
textColor: TextColors.primary
font: SF Pro Text, 17pt, 1.5x line height
alignment: Center or natural (varies)

// Visual Hierarchy
primaryText: 17pt, weight .semibold
supportingText: 15pt, weight .regular, secondary color
```

### Audio Player Component

```swift
// Compact, always visible

container:
  background: Glass (.ultraThinMaterial)
  cornerRadius: 12pt
  padding: 12pt
  height: 64pt
  
layout: Horizontal
  - Icon: Play/pause (24pt, rose)
  - Text: "Sleep: Ocean Waves" (15pt, primary)
  - Time: "12:34" (SF Mono, 13pt, secondary)
  - Close: X button (20pt)

// States
playing: Progress bar animated, icon paused
paused: Play icon, no animation
completed: Checkmark, emerald accent

// Tap behavior
drag slider to seek, tap play/pause
```

### Notification Card (Widget Preview)

```swift
// Lock screen or home screen widget representation

container:
  background: Glass with dark tint
  cornerRadius: 16pt
  padding: 12pt
  size: Small (SW widget) or Medium

content:
  - Image: 80x80pt or 160x160pt
  - Title: 15pt, bold
  - Message: 13pt, secondary color
  
// Update frequency
refreshed: 4x daily at notification times
or on-demand when widget tapped
```

---

## 🎯 Core Screens

### Home Dashboard

**Layout:**
```
Navigation Bar
  - Title: "Hopecore" (or app name)
  - Settings icon (right)
  
Today's Message Card (featured)
  - Full image-text pairing
  - Share + Save buttons below
  - Swipe down to dismiss
  
Audio Quick Access (if relevant)
  - "Sleep Sounds" button (56pt)
  - "Focus Music" button (56pt)
  - Status: Playing/Ready/Not started
  
Recent Messages (scrollable)
  - Thumbnail cards (4:3 aspect)
  - Grid layout, 2 columns
  - Tap to expand full card
  
Floating Action Buttons
  - Browse All (bottom left)
  - Settings (bottom right)
```

**Spacing:**
- Screen margins: 20pt
- Sections: 24pt apart
- Card gap: 12pt

---

### Message Browser

**Layout:**
```
Navigation Bar
  - Title: "Messages" (left)
  - Back/close (left)
  - Category filter (right)

Category Tabs
  - All
  - Resilience
  - Agency
  - Rebuilding
  - Possibility
  - Custom collections
  
Grid of Message Cards
  - 2 columns
  - 12pt gap
  - Height: auto (4:3 aspect ratio)
  - Tap to view full
  
Pagination
  - Infinite scroll
  - Load more at bottom
```

---

### Full Message View

**Layout:**
```
Navigation Bar
  - Back button (left)
  - Share (center)
  - Save (right, filled if saved)
  
Message Card (full screen)
  - Padding: 20pt
  - Image at top (max 300pt height)
  - Text below (scrollable if long)
  
Below Message
  - Category badge: "Resilience" (rose accent)
  - Source credit: "By [author]" (secondary text)
  - Timestamp: "Today, 9:30 AM" (tertiary, mono)
  
Related Messages (at bottom)
  - "You might also like..."
  - 3-4 cards, horizontal scroll
```

---

### Audio Sessions

#### Browse Audio

**Layout:**
```
Navigation Bar
  - Title: "Audio" (left)
  - Search (right)

Category Sections
  1. Sleep Sounds
     - Cards: 2 column grid
     - Duration: SF Mono, 13pt
     - Icon: Moon (12pt)
     
  2. Focus Sessions
     - Cards: 2 column grid
     - Duration: SF Mono, 13pt
     - Icon: Focus/play (12pt)

Card Content
  - Thumbnail (60x60pt or full width)
  - Title: SF Pro Text, 15pt
  - Duration: SF Mono, 13pt
  - Play button overlay on hover
```

#### Playing Audio

**Layout:**
```
Full Screen (no nav bar during playback)

Large Player
  - Album art: 240x240pt centered
  - Title: SF Pro Display, 22pt (centered)
  - Duration: SF Mono, 17pt (centered)
  
Progress Bar
  - Full width slider
  - Current/total time in SF Mono
  - 8pt height, emerald fill
  
Playback Controls (3 buttons)
  - Previous (gray if no previous)
  - Play/Pause (56pt, rose, large)
  - Next (gray if no next)
  
Volume + Settings
  - Volume slider
  - Speed selector (1x, 1.25x, 1.5x)
  - Sleep timer (15/30/60 min)
  
Floating Close
  - X button (top right, white)
```

---

### Saved Messages / Collection

**Layout:**
```
Navigation Bar
  - Title: "Saved" (left)
  - Sort menu (right: newest/oldest/category)

Tabs
  - All Saved
  - Collections (custom)

Grid View (2 columns)
  - Message cards with filled heart indicator
  - Tap to view full
  - Long press to edit/delete
  
Empty State
  - Icon + message
  - "Save messages to build your collection"
  - CTA: "Browse Messages"
```

---

### Notification Settings

**Layout:**
```
Navigation Bar
  - Title: "Notifications" (left)
  - Back (left)
  - Done (right)

Frequency Section
  - Slider: 1-10 per day
  - Label: "Messages per day"
  
Timing Section
  - Start time: Time picker
  - End time: Time picker
  - Quiet hours toggle
  
Message Categories
  - Toggle for each category
  - Checkmarks in glass cards
  
Sound & Haptics
  - Sound toggle + selector
  - Haptic toggle
  - Preview button
  
CTA: "Save Settings"
  - Rose/magenta accent
  - 56pt height
```

---

## 🎨 Visual Patterns

### Message Card Presentation Modes

**Mode 1: Illustration + Centered Text**
```
[Illustration centered]
[Whitespace: 16pt]
[Centered quote text]
[Whitespace: 8pt]
[Optional: Author/source]
```

**Mode 2: Image Background + Overlaid Text**
```
[Background image: opacity 0.4]
[Text overlay: white, centered]
[Optional: Gradient overlay for readability]
```

**Mode 3: Split Layout**
```
[Left: Image 50% width]
[Right: Text 50% width]
[Vertical center alignment]
```

**Mode 4: Minimal Text + Subtle Background**
```
[Subtle background texture: opacity 0.2]
[Generous whitespace]
[Centered text]
[Typography carries the weight]
```

---

### Micro-Interactions

**Message Tap:**
- Scale in: 0.95 → 1.0, 0.2s spring
- Fade in text content: 0s → 1s, 0.3s delay
- Haptic: light impact

**Save Button:**
- Heart icon: scale(0.8 → 1.2 → 1.0), 0.4s spring
- Color: gray → rose, 0.2s easeOut
- Haptic: success notification

**Audio Play:**
- Play icon → pause icon: crossfade, 0.15s
- Progress bar: animated fill, real-time
- Haptic: light impact on play/pause

**Share Action:**
- Sheet slides up: 0.35s spring
- Options fade in: staggered 0.1s

---

## 🔍 Depth & Elevation

### Material Strategy

*Identical to NoGoon: Native iOS materials for depth, zero custom shadows*

```swift
struct Elevation {
    // Primary pattern: Glass materials
    static let card = UIBlurEffect.Style.systemUltraThinMaterialDark
    static let modal = UIBlurEffect.Style.systemMaterialDark
    static let sheet = UIBlurEffect.Style.systemMaterialDark
    
    // Secondary pattern: Solid elevated surfaces
    static let audioPlayer = BackgroundColors.elevated
    static let chatBubble = BackgroundColors.elevated
    static let inputField = BackgroundColors.tertiary
    
    // Special case: Never use shadow
    // (No crisis context requiring panic button distinction)
}
```

### Depth Hierarchy

**Level 0: Screen Background**
- Solid color: `BackgroundColors.primary` (#0A0E14)
- Always dark, consistent across all screens
- Provides neutral canvas for message content

**Level 1: Content Cards (Primary Pattern)**
- `.ultraThinMaterial` glass
- Most common pattern for:
  - Message cards (hero component)
  - Audio session browse cards
  - Collection cards
  - Category filter tabs
- Provides subtle depth without cognitive load
- Maintains spacious, calm feeling

**Level 2: Modals & Sheets**
- `.regularMaterial` glass
- More opaque than Level 1
- Use for:
  - Notification settings sheet
  - Category picker
  - Collection creation overlay
  - Audio player full screen

**Level 3: Special Elements**
- Solid backgrounds for specific interactions:
  - Audio player controls: `elevated` (#161B22)
  - Text input fields: `tertiary` (#1C2128)
  - Message text-on-background cards: `elevated`
- Glass creates cognitive load when reading long text or during playback

### Shadow Rules

**Use shadow on:**
- Nothing in hopecore app
- (No crisis-level elements requiring distinction)

**Never use shadow on:**
- Message cards (glass provides sufficient depth)
- Audio player (material hierarchy sufficient)
- Buttons
- List items
- Input fields
- Modals
- Navigation elements
- Any interactive component

### Material Application by Component

| Component | Material | Reasoning |
|-----------|----------|-----------|
| Message cards (image+text) | `.ultraThinMaterial` | Primary focus; glass provides depth without distraction |
| Message cards (text-on-bg) | `elevated` (solid) | Reading comfort; solid avoids blur interference with text |
| Audio browse cards | `.ultraThinMaterial` | Scannable collection; consistent with message cards |
| Audio now playing | `elevated` (solid) | Player UI needs clarity during interaction |
| Notification settings | `.regularMaterial` | Modal; more opaque for form clarity |
| Collection picker | `.regularMaterial` | Selection context; modal treatment |
| Primary buttons | None (solid color) | Direct interaction; no material needed |
| Navigation bars | None (solid color) | System-standard approach |

### Visual Consistency Principle

The material strategy maintains **calm through simplicity**:
- Glass materials (Level 1-2) create breathing room and visual hierarchy
- Solid backgrounds (Level 3) used only where reading/interaction demands focus
- No shadows anywhere (eliminates visual weight and complexity)
- Emerald and rose accents provide color hierarchy, not elevation

---

## 📱 Notification & Widget Strategy

### Daily Notification

**Timing:** User-selected times during active hours

**Content:**
- Title: Generic ("Your daily inspiration")
- Body: Message excerpt (max 150 chars)
- Image: Thumbnail of paired image (if available)

**Behavior:**
- Tap → Opens app to full message
- Swipe → Dismiss (don't show again today)
- Long press → Preview with save/share options

### Lock Screen Widget

**Format:** Small or Medium widget

**Display:**
- Daily message image (top 60%)
- Message excerpt (bottom 40%, 2 lines max)
- Visual: Glass material with rose border (2pt)

**Tap Behavior:**
- Opens app to that specific message
- Updates daily at primary notification time

---

## ✨ Animation & Transition Strategy

### Standard Timings

```swift
struct AnimationTiming {
    static let instant: TimeInterval = 0.1      // Immediate
    static let quick: TimeInterval = 0.2        // Button press
    static let standard: TimeInterval = 0.3     // Most transitions
    static let deliberate: TimeInterval = 0.5   // Modal entrance
    static let slow: TimeInterval = 1.0         // Audio playback progress
}
```

### Key Animations

**Message Card Entrance:**
- Fade in + scale: 0.9 → 1.0, 0.3s spring

**Audio Player Appearance:**
- Slide up from bottom: 0.35s spring
- Simultaneous opacity: 0 → 1, 0.25s easeOut

**Saved State Feedback:**
- Heart icon pulse: 0.4s spring overshoot
- Color transition: gray → rose, 0.2s easeOut

**Page Transitions:**
- Slide right (back): 0.3s easeInOut
- Fade (category switch): 0.2s easeOut

---

## 🎯 Interaction Principles

### One-Handed Design

**Tap Targets:**
- Minimum 44pt for all buttons
- Primary actions: Bottom third (thumb reach)
- Secondary actions: Center (comfortable reach)
- Navigation: Top (acceptable trade-off)

**Message Cards:**
- Full width, easy thumb scroll
- Save/Share buttons: Bottom (accessible)
- Swipe gestures for browsing

**Audio Player:**
- Play/pause: Center large button (56pt)
- Controls: Bottom aligned
- Draggable progress bar (spacious touch area)

### Haptic Feedback

```swift
struct HapticFeedback {
    // Light (common actions)
    static let lightActions = [
        "message tap",
        "audio play/pause",
        "category switch"
    ]
    
    // Medium (meaningful actions)
    static let mediumActions = [
        "save message",
        "share action",
        "collection create"
    ]
    
    // Success (achievements)
    static let successActions = [
        "message saved",
        "collection created",
        "milestone reached"
    ]
}
```

---

## 🚫 Anti-Patterns

### Don't:

❌ Make messages feel commercial or promotional
❌ Use images that are generic stock photos
❌ Add engagement metrics (views, likes, saves counts)
❌ Show "streaks" or achievement badges
❌ Use dark purple or desaturated blues
❌ Create dense, text-heavy layouts
❌ Interrupt audio with excessive notifications
❌ Use error messaging for missed notifications
❌ Add social sharing features (private app)
❌ Implement algorithms that prioritize certain messages
❌ Use red or warning-colored accents

### Do:

✅ Curate messages for authenticity and resonance
✅ Pair images intentionally with text
✅ Keep app minimal and focused
✅ Respect user's quiet hours and preferences
✅ Use rose/magenta as primary accent
✅ Maintain spacious, breathing layouts
✅ Let audio play without interruption
✅ Handle all states gracefully
✅ Prioritize privacy and user autonomy
✅ Surface diversity of messages equally
✅ Use emerald and warm amber accents

---

## 📋 Implementation Checklist

### Visual Design
- [ ] Dark background (#0A0E14) as primary
- [ ] Rose/magenta (#EC4899) for primary accent
- [ ] Emerald (#10B981) for secondary/progress
- [ ] Glass materials for all cards
- [ ] SF Mono for all numeric data
- [ ] 16pt corner radius for cards
- [ ] No drop shadows anywhere
- [ ] Proper text hierarchy (3 sizes max)

### Typography
- [ ] Display text max 28pt
- [ ] Body text minimum 15pt
- [ ] SF Pro Text for content
- [ ] SF Pro Rounded for buttons
- [ ] SF Mono for timestamps/durations
- [ ] 1.5x line height for message text
- [ ] Sentence case for UI labels
- [ ] All caps only for uppercase tracking

### Spacing
- [ ] Screen margins 20pt
- [ ] All spacing on 4pt grid
- [ ] Generous whitespace around cards
- [ ] 24pt minimum between sections
- [ ] Message cards 20pt padding
- [ ] Audio components 16pt padding

### Interaction
- [ ] 44pt minimum tap targets
- [ ] Primary actions bottom third
- [ ] Animations 0.2-0.3s standard
- [ ] Haptic feedback on key actions
- [ ] One-handed accessible layout
- [ ] Respects Reduce Motion setting

### Content
- [ ] Authentic, curated messaging
- [ ] Intentional image pairings
- [ ] Non-judgmental language
- [ ] No corporate/marketing tone
- [ ] Clear visual hierarchy
- [ ] Scannable in <3 seconds

### Audio
- [ ] Offline playback supported
- [ ] No interrupting notifications during play
- [ ] Clear progress indication
- [ ] Playback controls prominent
- [ ] Speed and timer options available

### Privacy
- [ ] No social sharing/external APIs
- [ ] Saved messages local storage
- [ ] No tracking or analytics
- [ ] Offline functionality maintained
- [ ] Generic notification content

---

## Version History

**v1.0** - Hopecore design system
- Forked from NoGoon core principles
- Established rose/magenta primary accent (warmth + possibility)
- Adapted for message-first, audio-complementary experience
- Focused on image-text pairing as core interaction
- Emphasized spacious, minimal UI
- Privacy-first, no social features
