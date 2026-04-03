# 🎯 Utilities: Magic numbers and SF Symbols extracted to typed enums

## 💡 Convention

No magic numbers or SF Symbol name strings in views. Extract them to the appropriate enum in `Utilities/Constants/`: `Dimensions`, `Space`, `Timing`, `Limits`, or `Icon`.

## 🏆 Benefits

- Searchable: finding all usages of a constant is a Swift symbol search, not a number hunt.
- Consistent: changing a value propagates everywhere automatically.
- Self-documenting: `Space.medium` communicates intent; `16` does not.
- Type-safe SF Symbols: `Icon.trash.rawValue` fails at compile time if the case is removed.

## 👀 Examples

### ✅ Good: Named constant from the appropriate enum

```swift
Image(systemName: Icon.trash.rawValue)
    .frame(width: Dimensions.stickyNoteSize)
    .padding(Space.medium)
```

### ❌ Bad: Inline magic number and raw SF Symbol string

```swift
Image(systemName: "trash")
    .frame(width: 160)
    .padding(16)
```

### ✅ Good: Adding a new icon to the `Icon` enum

```swift
enum Icon: String {
    case trash
    case sparkles
    case newFeature = "star.circle.fill"
}
```

### ❌ Bad: Using the SF Symbol name directly in the call site

```swift
Image(systemName: "star.circle.fill")
```

## 🧐 Real world examples

- [`Icon.swift`](../../kudos/Utilities/Constants/Icon.swift)

## 🔗 Related agreements

- [Localization via Copies and A11y enums](../localization/copies-a11y-localized-enums.md).
