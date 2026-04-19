import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) var languageManager

    var body: some View {
        List {
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
        .localized()
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
            .navigationTitle("Select language")
    }
    .environment(LanguageManager.shared)
}
