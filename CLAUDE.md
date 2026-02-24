# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Conventions

- **Responses**: Always respond in Spanish
- **Commits**: English (imperative, clear, brief)
- **Code** (variables, functions, classes, comments): English
- **User documentation** (README.md, docs/): Spanish

## Build and Run

Open `kudos.xcodeproj` in Xcode 15.0+ and run (⌘R). Requires iOS 17.0+ deployment target.

## Testing

```bash
# Run all tests from Xcode
⌘U

# Or via command line
xcodebuild test -project kudos.xcodeproj -scheme kudosTests -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -project kudos.xcodeproj -scheme kudosUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

- All new/modified functionality must have tests
- Tests must pass locally before committing
- If a test fails 3+ times intermittently, try an alternative approach; if that also fails 3 times, skip and document in `docs/testing-exceptions.md`

## Architecture

**SwiftUI + SwiftData app** for saving personal achievements as sticky notes.

### Key Patterns

- **MVVM**: ViewModels (e.g., `MainViewModel`) manage state for complex views
- **SwiftData**: `Accomplishment` model with `@Model`, persisted locally
- **Validation Layer**: `AccomplishmentValidator` validates before persistence (max 140 chars)
- **Localization**: `LanguageManager` singleton manages ES/EN with real-time switching. All strings in `Copies` and `A11y` enums use `.localized` extension

### Project Structure

```
kudos/
├── Model/Accomplishment.swift      # SwiftData model (text, color, photoData, date)
├── Views/
│   ├── Main/                       # MainView + MainViewModel
│   ├── Carousel/                   # Achievement gallery with swipe navigation
│   ├── Stickies/                   # Sticky note components
│   └── ...
├── Utilities/
│   ├── Constants/                  # Dimensions, Space, Timing, Limits, etc.
│   ├── Localization/               # Copies.swift, A11y.swift, LanguageManager
│   └── Validation/                 # AccomplishmentValidator, ValidationError
└── Confetti/                       # Celebration animation components
```

### State Management Guidelines

- Avoid many `@State` in one view; if >4 related states, use `@StateObject` with ViewModel or `@Observable`
- Use `@EnvironmentObject` for shared state (e.g., `LanguageManager`)
- Be pragmatic: if a ViewModel adds complexity without benefit, use simpler approach

### Constants

All magic numbers are extracted to `Utilities/Constants/`:
- `Dimensions` - UI sizes (sticky notes, text editor, etc.)
- `Space` - Spacing values
- `Timing` - Animation durations
- `Limits` - Character limits (maxCharacters = 140)

## Workflow Preferences

- **Before editing**: Read relevant files to understand context
- **After edits**: Check for lint issues in modified files
- **Confirmations**: Don't ask for obvious/safe changes; ask when there's functional ambiguity or risk
- **Response format**:
  - **Qué se cambió**: ...
  - **Por qué**: ...
  - **Archivos**: `path/file1`, `path/file2`
  - **Impacto**: ...
