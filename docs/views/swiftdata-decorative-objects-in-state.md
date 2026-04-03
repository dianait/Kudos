# 🎯 Views: Decorative `@Model` objects stored in `@State`, not created in `body`

## 💡 Convention

`@Model` class instances used purely for display (never persisted) must be declared as `@State private var`, not created inline in `body` or as computed properties. SwiftUI recreates view structs on every render, but `@State` persists the reference across re-renders.

## 🏆 Benefits

- Avoids allocating new `@Model` objects on every body evaluation.
- `@State` guarantees the instance is created once per view lifetime.
- Keeps `body` free of side-effect object construction.

## 👀 Examples

### ✅ Good: `@State` properties initialized once

```swift
struct StickiesView: View {
    @State private var placeholderItem = Accomplishment(
        validatedText: " ", validatedColor: Copies.Colors.yellow.rawValue
    )
    @State private var backgroundItem1 = Accomplishment(
        validatedText: Copies.StickisView.example1,
        validatedColor: Copies.Colors.green.rawValue
    )

    var body: some View {
        StickyView(item: lastItem ?? placeholderItem)
    }
}
```

### ❌ Bad: `@Model` objects created in a computed property (re-created every body eval)

```swift
private var placeholderItem: Accomplishment {
    Accomplishment(validatedText: " ", validatedColor: Copies.Colors.yellow.rawValue)
}

var body: some View {
    StickyView(item: lastItem ?? placeholderItem) // new object every render
}
```

### ❌ Bad: `@Model` objects created inline in `body`

```swift
var body: some View {
    StickyView(item: Accomplishment(validatedText: "Example", validatedColor: "green"))
}
```

## 🧐 Real world examples

- [`StickiesView.swift`](../../kudos/Views/Stickies/StickiesView.swift)

## 🔗 Related agreements

- [Cache UIImage conversions in @State](./cache-uiimage-in-state.md).
