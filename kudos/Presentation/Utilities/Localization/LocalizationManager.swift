import Foundation
import SwiftUI
import Observation
import os.lock

// MARK: - Thread-Safe Language Storage

/// Thread-safe storage for the current language
///
/// Uses modern `OSAllocatedUnfairLock` (iOS 16+) for fast, type-safe concurrent access.
/// This allows `localizedString(for:)` to be called safely from any thread without @MainActor isolation.
private final class LanguageStorage: Sendable {
    private let lock: OSAllocatedUnfairLock<String>

    init(_ language: String) {
        lock = OSAllocatedUnfairLock(initialState: language)
    }

    var current: String {
        lock.withLock { $0 }
    }

    func update(_ language: String) {
        lock.withLock { $0 = language }
    }
}

// MARK: - Language Manager

@Observable
@MainActor
final class LanguageManager {
    var currentLanguage: String {
        didSet {
            // Update thread-safe storage whenever language changes
            languageStorage.update(currentLanguage)
        }
    }

    /// Thread-safe storage for language access from any thread
    private let languageStorage: LanguageStorage

    static let shared: LanguageManager = {
        let instance = LanguageManager()
        return instance
    }()

    static let supportedLanguages = ["es", "en"]
    private static let languageKey = "selectedLanguage"

    private init() {
        // Determine initial language
        let systemLanguage = Locale.preferredLanguages.first ?? ""
        var initialLanguage = systemLanguage.starts(with: "es") ? "es" : "en"

        // Override with saved preference if available
        if let savedLanguage = UserDefaults.standard.string(forKey: Self.languageKey),
           Self.supportedLanguages.contains(savedLanguage) {
            initialLanguage = savedLanguage
        }

        self.currentLanguage = initialLanguage
        self.languageStorage = LanguageStorage(initialLanguage)
    }

    func setLanguage(_ language: String) {
        guard Self.supportedLanguages.contains(language) else { return }

        self.currentLanguage = language
        UserDefaults.standard.set(language, forKey: Self.languageKey)
    }

    /// Returns a localized string for the given key
    ///
    /// This method is `nonisolated` to allow usage from non-@MainActor contexts like
    /// ValidationError.errorDescription (which conforms to LocalizedError protocol).
    ///
    /// **Thread Safety:** Uses internal thread-safe storage (NSLock) to safely read
    /// the current language from any thread without requiring @MainActor isolation.
    nonisolated func localizedString(for key: String) -> String {
        // Read from thread-safe storage - safe from any thread
        let bundleLanguage = languageStorage.current

        if let path = Bundle.main.path(forResource: bundleLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, bundle: bundle, comment: "")
        }

        return NSLocalizedString(key, comment: "")
    }
}

