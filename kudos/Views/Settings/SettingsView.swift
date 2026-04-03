import SwiftUI

struct SettingsView: View {
    @Environment(LanguageManager.self) var languageManager
    @Environment(AppSettings.self) var appSettings
    @Environment(TipJarStore.self) var tipJarStore

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

            Section(Copies.TipJar.sectionTitle) {
                if tipJarStore.isSupporter {
                    HStack {
                        Image(systemName: Icon.heart.rawValue)
                            .foregroundStyle(.orange)
                        Text(Copies.TipJar.supporterThanks)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(Copies.TipJar.supporterBadge)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .padding(.horizontal, Space.small)
                            .padding(.vertical, Space.extraSmall)
                            .background(.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                } else {
                    Button {
                        showTipJar = true
                    } label: {
                        HStack {
                            Image(systemName: Icon.heart.rawValue)
                                .foregroundStyle(.orange)
                            Text(Copies.TipJar.supportButton)
                                .foregroundStyle(.primary)
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
        .scrollContentBackground(.hidden)
        .background(Color("MainBackground"))
        .navigationTitle(Copies.setingsTitle)
        .sheet(isPresented: $showTipJar) {
            TipJarView()
                .environment(tipJarStore)
                .presentationDetents([.medium])
        }
        .localized()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(LanguageManager.shared)
    .environment(AppSettings.shared)
    .environment(TipJarStore.shared)
}
