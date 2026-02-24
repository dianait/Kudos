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
final class AppSettings {
    var colorSchemePreference: AppColorScheme

    static let shared = AppSettings()
    private static let colorSchemeKey = "selectedColorScheme"

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.colorSchemeKey),
           let scheme = AppColorScheme(rawValue: saved) {
            self.colorSchemePreference = scheme
        } else {
            self.colorSchemePreference = .system
        }
    }

    func setColorScheme(_ scheme: AppColorScheme) {
        colorSchemePreference = scheme
        UserDefaults.standard.set(scheme.rawValue, forKey: Self.colorSchemeKey)
    }
}
