# Athena iOS App

**Strategic intelligence for elite performance.**

A comprehensive iOS application for track and field enthusiasts, providing real-time meet tracking, athlete insights, and AI-powered performance analysis.

## Architecture

Built with **SwiftUI** and **MVVM** pattern for clean, maintainable code:

- **Models**: Core data structures (Athlete, Meet, Event, Result, CompetitiveStoryline)
- **ViewModels**: State management and business logic (HomeViewModel, AthleteViewModel, MeetViewModel)
- **Views**: SwiftUI components organized by feature
- **Services**: API communication and notifications

## Features

### MVP Features
- ✅ Home feed with competitive storylines
- ✅ Athlete following and discovery
- ✅ Meet awareness with schedule and links
- ✅ Performance insights powered by AI
- ✅ Smart notifications for key events
- ✅ Settings and preferences

### Tabs
1. **Home** - Dashboard with trending storylines and upcoming meets
2. **Athletes** - Browse and follow elite track and field athletes
3. **Meets** - Discover upcoming competitions and watch live
4. **Settings** - Customize notifications and preferences

## Project Structure

```
Athena/
├── Models/
│   ├── Athlete.swift
│   ├── Meet.swift
│   ├── Event.swift
│   ├── Result.swift
│   └── CompetitiveStoryline.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── AthleteViewModel.swift
│   └── MeetViewModel.swift
├── Views/
│   ├── AthenaApp.swift
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── AthleteView.swift
│   ├── MeetView.swift
│   └── SettingsView.swift
├── Services/
│   ├── APIService.swift
│   └── NotificationService.swift
└── Package.swift
```

## Tech Stack

- **Language**: Swift 6.2+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Minimum iOS**: 17.0
- **Data**: Codable JSON parsing
- **Notifications**: UserNotifications framework
- **Concurrency**: async/await

## API Integration

The app connects to a backend API (configured in `APIService.swift`) with endpoints for:

- `/athletes` - Athlete data and following
- `/meets` - Meet information and schedules
- `/events/{eventID}/results` - Event results
- `/storylines` - AI-generated competitive insights

## Getting Started

1. **Open in Xcode**: Open the project folder in Xcode 16+
2. **Select Target**: Ensure the Athena target is selected
3. **Configure Signing**: Set your development team in project settings
4. **Run**: Select a simulator (iOS 17+) and press Run

## Building for Production

```bash
swift build
```

## Development Notes

- Models use `@Observable` for reactive state management
- All API calls use async/await for modern concurrency
- Views follow single-responsibility principle
- Environment objects passed through SwiftUI's `.environment()` modifier
- Notifications require user permission (requested on app launch)

## Data Source Inspiration

- World Athletics Stats Zone
- FloTrack Rankings
- Track and Field News
- LA28 Athletics
- Hugging Face AI Models

## Future Enhancements

- Advanced filtering and search
- User authentication
- Offline data caching
- Apple Watch companion app
- Share functionality
- Custom alerts and reminders
- Social features (compare stats, leaderboards)

## License

Copyright © 2026 Alexandra McCoy
