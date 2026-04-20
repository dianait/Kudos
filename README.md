# 🎉 Kudos

[Español](README.es.md) | **English**

An iOS app to save and celebrate your personal achievements as digital sticky notes.

🌐 [dianait.blog/kudos](https://dianait.blog/kudos)

## ✨ Features

- **Save achievements**: Create sticky notes with your achievements and personal victories
- **Visual counter**: See how many achievements you've saved in your collection
- **Celebration animations**: Animated confetti when you save a new achievement
- **Achievement carousel**: Navigate through all your saved achievements with a swipe gesture
- **Delete from carousel**: Remove achievements directly from the carousel without entering detail view
- **Photo support**: Attach a photo to any achievement
- **Multi-language**: Spanish and English with real-time switching
- **Complete privacy**: All data is stored locally on your device, nothing leaves your phone
- **Accessibility**: Full VoiceOver support with localized labels and hints

## 📖 How to Use

1. **Add an achievement**: Tap the sticky note on the main screen, write your achievement, swipe up to save
2. **View your achievements**: Tap the counter at the top to open the carousel, swipe to navigate
3. **Delete an achievement**: Tap the trash icon on the active note in the carousel
4. **Change language**: Settings tab → select your preferred language

## 🏗️ Architecture

Kudos is built with **Clean Architecture** and **MVVM**, keeping the dependency rule strictly: Domain has no external dependencies.

```
kudos/
├── Domain/
│   ├── Models/              # AccomplishmentItem, NewAccomplishment
│   ├── Protocols/           # Use case + repository contracts
│   ├── UseCases/            # AddAccomplishment, AddPhotoAccomplishment (business logic only — pure pass-throughs removed)
│   └── Utilities/Validators # AccomplishmentValidator, ValidationError
├── Data/
│   ├── Entities/            # AccomplishmentEntity (@Model, SwiftData)
│   └── Repositories/        # AccomplishmentRepository (SwiftData impl)
├── Presentation/
│   ├── Main/                # MainView + MainViewModel
│   ├── Carousel/            # CarouselView, AccomplishmentDetailView
│   ├── Stickies/            # StickyView and subcomponents
│   ├── Settings/            # SettingsView
│   ├── AboutMe/             # AboutView
│   ├── Error/               # ErrorView
│   └── Utilities/
│       ├── Constants/       # Dimensions, Space, Timing, Icon, etc.
│       ├── Localization/    # Copies, A11y, LanguageManager
│       └── Confetti/        # Celebration animation components
├── Dependencies/
│   └── AppFactory.swift     # Dependency injection
└── Services/
    ├── AppSettings.swift
    └── LocalizationManager.swift
```

### Tech Stack

| | |
|---|---|
| Language | Swift 6 |
| UI | SwiftUI |
| Persistence | SwiftData |
| Min iOS | 17.0 |
| Xcode | 15.0+ |
| Concurrency | Swift 6, strict concurrency complete |

### Key Patterns

- **Clean Architecture**: Domain → Data → Presentation, dependency rule enforced
- **MVVM**: `MainViewModel` manages presentation state
- **Protocol-based DI**: Use cases and repository injected via protocols; ViewModel calls repository directly for simple fetch/delete (no use case when there's no business logic)
- **Validation layer**: `AccomplishmentValidator` in Domain, not in views
- **Localization**: `Copies` and `A11y` enums with `.localized` extension, real-time language switching
- **Swift 6 concurrency**: all types fully isolated (`@MainActor` on ViewModels, use cases, and repository); image compression offloaded to background thread

## 🔒 Privacy

All data lives on your device. No analytics, no external servers, no tracking.

## 🧪 Testing

```bash
# Unit + UI tests
xcodebuild test -project kudos.xcodeproj -scheme kudosTests -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -project kudos.xcodeproj -scheme kudosUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 👤 Author

Developed with ❤️ by [@Dianait](https://dianait.blog)
