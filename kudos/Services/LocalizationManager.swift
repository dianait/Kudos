import Foundation
import Observation

@Observable
@MainActor
final class LanguageManager {
    var currentLanguage: String

    static let shared: LanguageManager = {
        LanguageManager()
    }()

    static let supportedLanguages = ["es", "en"]
    nonisolated static let languageKey = "selectedLanguage"

    private init() {
        let systemLanguage = Locale.preferredLanguages.first ?? ""
        var initialLanguage = systemLanguage.starts(with: "es") ? "es" : "en"

        if let savedLanguage = UserDefaults.standard.string(forKey: Self.languageKey),
           Self.supportedLanguages.contains(savedLanguage) {
            initialLanguage = savedLanguage
        }

        self.currentLanguage = initialLanguage
    }

    var locale: Locale {
        Locale(identifier: currentLanguage == "es" ? "es_ES" : "en_US")
    }

    func setLanguage(_ language: String) {
        guard Self.supportedLanguages.contains(language) else { return }
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: Self.languageKey)
    }

    nonisolated static func localizedString(for key: String) -> String {
        let lang = UserDefaults.standard.string(forKey: Self.languageKey) ?? "en"
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
