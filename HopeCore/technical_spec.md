# Hopecore App - Product Outline

## Core Concept
A standalone iOS app delivering visceral, agency-focused hopecore messages throughout the day, complemented by curated sleep and focus audio content. Designed for users rebuilding their lives and seeking genuine possibility narratives rather than generic motivation. 

## Primary User Value
Users receive timely reminders that reinforce resilience, agency, and the possibility of meaningful change—emotionally calibrated for people in recovery or rebuilding phases.

---

## Feature Set

### 1. Hopecore Notifications
- **Customizable notification schedule**: Users set frequency (1-10 per day) and preferred time windows
- **Category selection**: Users choose which types of hopecore messages resonate (e.g., "Resilience," "Agency," "Rebuilding," "Possibility") Messages will also have a "Demotivation" category
- **Free users will be limited to 5 messages a day.** Premium users can have up to 20. Free users will receive one negative message for every 5 messages that send. Becoming a premium users will turn off negative messages by default
- **Mixed presentation formats**: 
  - **Custom image-text pairings**: Select messages pair custom imagery with text, where the image amplifies the emotional/visceral quality (e.g., illustrated figures, specific photography) These will be maximized for shareability. Screenshots downloaded will have the name of the app and our company in the bottom right in small font
  - **Text-on-background**: Other messages use text overlaid on curated background imagery/textures
- **Full-screen card presentation**: Messages are presented as complete visual cards (image + text) rather than generic treatment inside the app
- **Save/favorite system**: Users can bookmark messages (and their paired imagery) that particularly resonate
- **Share functionality**: Users can share individual message cards (complete with imagery) to social platforms—design intent is maintained across shares

### 2. Audio Content Library
- **Sleep sounds**: 10-15 minute curated tracks designed for wind-down (gentle, non-stimulating)
- **Focus/work sessions**: 5-30 minute ambient audio for focused work blocks
- **Minimal but quality**: Original recordings or carefully curated content (not attempting to compete with Calm)
- **In-app playback**: Simple, distraction-free player with playback controls
- **Offline access**: Audio files available for offline listening

### 3. Onboarding & Personalization
- **Initial setup flow**: Users answer brief questions about their situation (e.g., "What brought you here?" "Which areas of life are you rebuilding?")
- **Notification timing**: Set preferred times for notifications
- **Demotivation Messages**: Inform free users that part of the program is receiving demotivtaional messages if they're not subscribed to premium. 

### 4. Home Screen Interface
- **Today's message**: Featured hopecore message displayed prominently. Only one message displayed at a time. Users will be able to scroll vertically like they're on instagram or tiktok to see more messages'
- **Simple Overlay**: Users can favorite or share directly from the homepage. 
- **Quick access**: Users can start music directly from the homepage. Selecting the music icon will open an overlay with music selection and start, pause, next options. 
- **Saved collection**: Quick access to favorite messages
- **Settings**: Contains options for notifications, an option for signing up for premium, access to toggle on demotivational messages if they're premium subscribers'

### 5. Widget Support
- **Lock screen widget**: Displays current day's hopecore message
- **Home screen widget**: Shows featured message + quick audio shortcuts
- **Interactive widgets**: Allow users to like/save messages directly from widget
- **Multiple sizes**: Supports small, medium, and large widget configurations

### 6. Image Store
- **R2 Cloudflare**: Will host are text + image combinations so that the app is not too bloated. We should pre-load a random set of 3 images for users so they are cached in the morning of each day.

---

## Technical Scope

### Data Model
- Hopecore message library (stored locally or from lightweight backend)
- User preferences (categories, notification times, favorited messages)
- Audio file storage and streaming

### Notification System
- Local notifications with configurable schedule
- Rich notification payloads with full message text
- Custom notification sounds (optional)

### Audio Playback
- Native AVPlayer for audio streaming/playback
- Background audio capability for uninterrupted listening
- Offline caching of audio files

### Widgets
- Lock screen and home screen widget support
- Minimal data refresh once daily for free users, corresponds to notifcation schedule for premium users. 

### User Data
- Minimal storage: favorites, preferences, notification settings
- No authentication required (unless adding sync across devices)


---

## Brand/Tone Guidelines
- **Visual intentionality**: Imagery (whether custom illustration/photography or background textures) is deliberately paired with text to reinforce emotional resonance. Some messages use custom image-text pairings where the imagery is inseparable from the message; others use background imagery to set tone
- **Visceral, not sanitized**: Messages should feel grounded and real, acknowledging difficulty while emphasizing agency
- **Possibility-focused**: Center on what's possible, not just overcoming obstacles
- **Recovery-aware**: Language and imagery that resonates with people rebuilding lives
