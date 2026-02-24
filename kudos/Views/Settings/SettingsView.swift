import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) var languageManager
    @Environment(AppSettings.self) var appSettings

    var body: some View {
        @Bindable var appSettings = appSettings

        List {
            Section(Copies.LanguageSettingsView.title) {
                Button {
                    languageManager.setLanguage("es")
                } label: {
                    HStack {
                        Text("🇪🇸")
                        Text("Español")
                            .foregroundStyle(.primary)
                        Spacer()
                        if languageManager.currentLanguage == "es" {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }

                Button {
                    languageManager.setLanguage("en")
                } label: {
                    HStack {
                        Text("🇬🇧")
                        Text("English")
                            .foregroundStyle(.primary)
                        Spacer()
                        if languageManager.currentLanguage == "en" {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }

            Section(Copies.SettingsView.appearanceSection) {
                Picker(
                    Copies.SettingsView.colorSchemeLabel,
                    selection: Binding(
                        get: { appSettings.colorSchemePreference },
                        set: { appSettings.setColorScheme($0) }
                    )
                ) {
                    ForEach(AppColorScheme.allCases, id: \.self) { scheme in
                        Label(scheme.label, systemImage: scheme.icon)
                            .tag(scheme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle(Copies.setingsTitle)
        .localized()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(LanguageManager.shared)
    .environment(AppSettings.shared)
}
