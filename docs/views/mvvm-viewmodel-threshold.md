# 🎯 Views: Use ViewModel only when local state exceeds 4 related properties

## 💡 Convention

Keep `@State` properties directly in a view until there are more than 4 related state properties or the logic becomes non-trivial. At that threshold, extract to a `@StateObject` with `@Observable` ViewModel.

## 🏆 Benefits

- Avoids premature abstraction: simple views stay simple.
- Testability: extracted ViewModels can be unit-tested independently of SwiftUI.
- Readability: the threshold prevents views from becoming state managers with dozens of `@State` vars.

## 👀 Examples

### ✅ Good: Simple view keeps state inline

```swift
struct StickyNoteView: View {
    @State private var isEditing = false
    @State private var showConfirmation = false

    var body: some View { ... }
}
```

### ❌ Bad: ViewModel created for trivial state

```swift
@Observable
class StickyNoteViewModel {
    var isEditing = false
    var showConfirmation = false
}

struct StickyNoteView: View {
    @StateObject private var viewModel = StickyNoteViewModel()
    ...
}
```

### ✅ Good: ViewModel justified by complex state and logic

```swift
@Observable
class MainViewModel {
    var accomplishments: [Accomplishment] = []
    var selectedColor: StickyColor = .yellow
    var inputText: String = ""
    var isShowingEditor: Bool = false
    var validationError: ValidationError? = nil

    func save() { ... }
    func delete(_ item: Accomplishment) { ... }
}
```

## 🧐 Real world examples

- [`MainViewModel.swift`](../../kudos/Views/Main/MainViewModel.swift)

## 🔗 Related agreements

- [Constants extracted to typed enums](../utilities/constants-as-typed-enums.md).
