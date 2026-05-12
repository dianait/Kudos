import Testing
import Foundation
@testable import kudos

@Suite("LocalizationManager.resolveLanguage")
struct LocalizationManagerResolveLanguageTests {

    @Test(
        "resolveLanguage selects the correct language",
        arguments: [
            (saved: String?("es"), system: "en-US", expected: "es"),
            (saved: String?("en"), system: "es-ES", expected: "en"),
            (saved: String?("fr"), system: "es-ES", expected: "es"),
            (saved: String?(nil), system: "es-ES", expected: "es"),
            (saved: String?(nil), system: "en-US", expected: "en"),
            (saved: String?(nil), system: "", expected: "en"),
            (saved: String?(""), system: "es-ES", expected: "es")
        ] as [(saved: String?, system: String, expected: String)]
    )
    func resolveLanguagePicksExpected(saved: String?, system: String, expected: String) {
        let lang = LocalizationManager.resolveLanguage(savedLanguage: saved, systemLanguage: system)

        #expect(lang == expected)
    }

    @Test(
        "Common Spanish locale identifiers all map to 'es'",
        arguments: ["es", "es-ES", "es-MX", "es-419", "es_ES"]
    )
    func variousSpanishLocales(systemLanguage: String) {
        let lang = LocalizationManager.resolveLanguage(savedLanguage: nil, systemLanguage: systemLanguage)

        #expect(lang == "es")
    }
}

@Suite("LocalizationManager persistence", .serialized)
@MainActor
struct LocalizationManagerPersistenceTests {

    @Test("setLanguage persists to UserDefaults and updates currentLanguage")
    func setLanguagePersists() {
        withRestoredLanguageDefault {
            let target = LocalizationManager.shared.currentLanguage == "es" ? "en" : "es"
            LocalizationManager.shared.setLanguage(target)

            #expect(LocalizationManager.shared.currentLanguage == target)
            #expect(UserDefaults.standard.string(forKey: LocalizationManager.languageKey) == target)
        }
    }

    @Test("setLanguage with unsupported language is ignored")
    func setLanguageRejectsUnsupported() {
        withRestoredLanguageDefault {
            let before = LocalizationManager.shared.currentLanguage
            LocalizationManager.shared.setLanguage("fr")

            #expect(LocalizationManager.shared.currentLanguage == before)
        }
    }

    @Test(
        "localizedString returns text consistent with currentLanguage",
        arguments: [
            (lang: "es", expected: "Inicio"),
            (lang: "en", expected: "Home")
        ] as [(lang: String, expected: String)]
    )
    func localizedStringMatchesCurrentLanguage(lang: String, expected: String) {
        withRestoredLanguageDefault {
            LocalizationManager.shared.setLanguage(lang)

            #expect(LocalizationManager.localizedString(for: "home_tab") == expected)
        }
    }

    private func withRestoredLanguageDefault(_ body: () -> Void) {
        let key = LocalizationManager.languageKey
        let original = UserDefaults.standard.string(forKey: key)
        defer {
            if let original {
                UserDefaults.standard.set(original, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        body()
    }
}
