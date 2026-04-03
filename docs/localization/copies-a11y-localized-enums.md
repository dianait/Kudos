# 🎯 Localization: All strings go through `Copies` or `A11y` enums with `.localized`

## 💡 Convention

Never use string literals for user-facing text or accessibility labels. Declare them as static properties in `Copies` (UI text) or `A11y` (accessibility), and access them via the `.localized` extension on `String`.

## 🏆 Benefits

- Single source of truth: every visible string is discoverable from one place.
- Real-time language switching: `LanguageManager` triggers re-renders without restarting the app.
- Compile-time safety: refactoring a key is a Swift rename, not a grep-and-pray across `.strings` files.
- Separation of concerns: views contain no raw strings, only typed references.

## 👀 Examples

### ✅ Good: Use `Copies` enum property with `.localized`

```swift
Text(Copies.editTitle)
```

### ❌ Bad: Inline string literal in view

```swift
Text("Edit")
Text(NSLocalizedString("edit_title", comment: ""))
```

### ✅ Good: Nested namespace for a specific view

```swift
enum SettingsView {
    static var generalSection: String { "settings_general_section".localized }
}

// Usage
Text(Copies.SettingsView.generalSection)
```

### ❌ Bad: Flat key with view prefix in the string

```swift
Text("settings_general_section".localized)
```

## 🧐 Real world examples

- [`Copies.swift`](../../kudos/Utilities/Localization/Copies.swift)
- [`SettingsView.swift`](../../kudos/Views/Settings/SettingsView.swift)

## 🔗 Related agreements

- [Accessibility labels via A11y enum](./a11y-enum.md).
