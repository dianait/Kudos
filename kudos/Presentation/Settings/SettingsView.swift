import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) var languageManager
    @Environment(AppSettings.self) var appSettings

    @State private var showTipJar = false

    private let languages: [(code: String, flag: String, name: String)] = [
        ("es", "🇪🇸", "Español"),
        ("en", "🇬🇧", "English")
    ]

    var body: some View {
        @Bindable var appSettings = appSettings

        List {
            Section(Copies.LanguageSettingsView.title) {
                ForEach(languages, id: \.code) { lang in
                    Button {
                        languageManager.setLanguage(lang.code)
                    } label: {
                        HStack {
                            Text(lang.flag)
                            Text(lang.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if languageManager.currentLanguage == lang.code {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            
            Section(Copies.SettingsView.appearanceSection) {
                Picker(Copies.SettingsView.colorSchemeLabel, selection: $appSettings.colorSchemePreference) {
                    ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                        Label(scheme.label, systemImage: scheme.icon)
                            .tag(scheme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(LanguageManager.shared)
    .environment(AppSettings.shared)
}
