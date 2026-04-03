# 🎯 Views: Cache `UIImage` conversions in `@State`, never in `body`

## 💡 Convention

Never call `UIImage(data:)` directly inside `body` or computed view properties. Cache the result in `@State` and update it with `.task(id:)` or `.onChange(of:)`.

## 🏆 Benefits

- Avoids expensive memory allocation on every re-render.
- `UIImage(data:)` runs only when the underlying `Data` actually changes.
- Keeps `body` pure and free of side effects.

## 👀 Examples

### ✅ Good: Cached with `.task(id:)`

```swift
struct StickyView: View {
    var item: Accomplishment
    @State private var cachedImage: UIImage?

    var body: some View {
        Group {
            if let image = cachedImage {
                Image(uiImage: image)
            } else {
                placeholder
            }
        }
        .task(id: item.photoData) {
            cachedImage = item.photoData.flatMap { UIImage(data: $0) }
        }
    }
}
```

### ✅ Good: Cached with `.onAppear` + `.onChange(of:)` for `@Binding` data

```swift
@State private var cachedPreviewImage: UIImage?

var body: some View { ... }
    .onAppear {
        cachedPreviewImage = selectedPhotoData.flatMap { UIImage(data: $0) }
    }
    .onChange(of: selectedPhotoData) { _, newData in
        cachedPreviewImage = newData.flatMap { UIImage(data: $0) }
    }
```

### ❌ Bad: `UIImage(data:)` inline in `body`

```swift
var body: some View {
    if let data = item.photoData, let image = UIImage(data: data) {
        Image(uiImage: image)
    }
}
```

## 🧐 Real world examples

- [`StickyView.swift`](../../kudos/Views/Stickies/Sticky/StickyView.swift)
- [`StickiesViewOverview.swift`](../../kudos/Views/Stickies/StickiesViewOverview.swift)

## 🔗 Related agreements

- [Decorative SwiftData objects cached in @State](./swiftdata-decorative-objects-in-state.md).
