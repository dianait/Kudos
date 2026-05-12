import SwiftUI
import Observation

enum AppColorScheme: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "settings_color_scheme_system".localized
        case .light: return "settings_color_scheme_light".localized
        case .dark: return "settings_color_scheme_dark".localized
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

@Observable
@MainActor
final class AppSettings: OnboardingStateStoreProtocol {
    var colorSchemePreference: AppColorScheme {
        didSet { UserDefaults.standard.set(colorSchemePreference.rawValue, forKey: Self.colorSchemeKey) }
    }

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Self.onboardingKey) }
    }

    static let shared = AppSettings()
    private static let colorSchemeKey = "selectedColorScheme"
    private static let onboardingKey = "hasCompletedOnboarding"

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.colorSchemeKey),
           let scheme = AppColorScheme(rawValue: saved) {
            self.colorSchemePreference = scheme
        } else {
            self.colorSchemePreference = .system
        }

        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Self.onboardingKey)
    }
}
