# 🎯 Utilities: Side effects on `@Observable` properties go in `didSet`, not in separate methods

## 💡 Convention

When an `@Observable` class property needs a side effect on change (e.g., persist to `UserDefaults`), put the logic in `didSet` on the property itself. Don't create a separate setter method that duplicates the assignment.

## 🏆 Benefits

- Enables using `$bindable.property` directly in SwiftUI without manual `Binding(get:set:)`.
- Single source of truth: all effects are co-located with the property.
- Eliminates boilerplate `Binding(get:set:)` in views.

## 👀 Examples

### ✅ Good: `didSet` on the property, `$appSettings.colorSchemePreference` in view

```swift
// AppSettings.swift
@Observable @MainActor
final class AppSettings {
    var colorSchemePreference: AppColorScheme {
        didSet { UserDefaults.standard.set(colorSchemePreference.rawValue, forKey: colorSchemeKey) }
    }
}

// SettingsView.swift
Picker(label, selection: $appSettings.colorSchemePreference) { ... }
```

### ❌ Bad: Separate setter method forces manual `Binding(get:set:)` in view

```swift
// AppSettings.swift
var colorSchemePreference: AppColorScheme

func setColorScheme(_ scheme: AppColorScheme) {
    colorSchemePreference = scheme
    UserDefaults.standard.set(scheme.rawValue, forKey: colorSchemeKey)
}

// SettingsView.swift — verbose and fragile
Picker(label, selection: Binding(
    get: { appSettings.colorSchemePreference },
    set: { appSettings.setColorScheme($0) }
)) { ... }
```

## ☝️ Exceptional cases: When to not take into account this convention

If the side effect is async (e.g., calling an API), `didSet` is not appropriate. Use a `Task { await persist() }` pattern or keep a separate method and accept the manual `Binding`.

## 🧐 Real world examples

- [`AppSettings.swift`](../../kudos/Utilities/AppSettings.swift)
- [`SettingsView.swift`](../../kudos/Views/Settings/SettingsView.swift)

## 🔗 Related agreements

- [MVVM ViewModel threshold](../views/mvvm-viewmodel-threshold.md).
