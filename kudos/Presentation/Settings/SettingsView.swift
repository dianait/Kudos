import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) var languageManager
    @Environment(AppSettings.self) var appSettings

    @State private var showTipJar = false
    @State private var onboardingPresentation: OnboardingPresentation?

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

            Section(Copies.SettingsView.generalSection) {
                Button {
                    presentOnboarding()
                } label: {
                    Label(Copies.SettingsView.showOnboarding, systemImage: "sparkles")
                        .foregroundStyle(.primary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("MainBackground"))
        .fullScreenCover(item: $onboardingPresentation) { presentation in
            OnboardingView(viewModel: presentation.viewModel)
                .environment(languageManager)
        }
    }

    private func presentOnboarding() {
        let viewModel = OnboardingViewModel { onboardingPresentation = nil }
        onboardingPresentation = OnboardingPresentation(viewModel: viewModel)
    }
}

private struct OnboardingPresentation: Identifiable {
    let id = UUID()
    let viewModel: OnboardingViewModel
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(LocalizationManager.shared)
    .environment(AppSettings.shared)
}
