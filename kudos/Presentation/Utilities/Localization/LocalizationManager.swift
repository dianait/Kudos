import Foundation
import Observation

@Observable
@MainActor
final class LocalizationManager {
    var currentLanguage: String

    static let shared: LocalizationManager = {
        LocalizationManager()
    }()

    nonisolated static let supportedLanguages = ["es", "en"]
    nonisolated static let languageKey = "selectedLanguage"
    private nonisolated static let defaultLanguage = "en"

    private init() {
        let resolvedLanguage = Self.resolveLanguage()
        self.currentLanguage = resolvedLanguage

        if UserDefaults.standard.string(forKey: Self.languageKey) == nil {
            UserDefaults.standard.set(resolvedLanguage, forKey: Self.languageKey)
        }
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
        let lang = resolveLanguage()
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    private nonisolated static func resolveLanguage() -> String {
        resolveLanguage(
            savedLanguage: UserDefaults.standard.string(forKey: languageKey),
            systemLanguage: Locale.preferredLanguages.first ?? ""
        )
    }

    nonisolated static func resolveLanguage(savedLanguage: String?, systemLanguage: String) -> String {
        if let saved = savedLanguage, supportedLanguages.contains(saved) {
            return saved
        }
        return systemLanguage.starts(with: "es") ? "es" : defaultLanguage
    }
}
