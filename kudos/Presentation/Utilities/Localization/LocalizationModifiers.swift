import SwiftUI

struct LocalizationViewModifier: ViewModifier {
    @Environment(LanguageManager.self) var languageManager

    func body(content: Content) -> some View {
        content
            .id(languageManager.currentLanguage)
    }
}

extension View {
    func localized() -> some View {
        self.modifier(LocalizationViewModifier())
    }
}
