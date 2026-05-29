import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(LocalizationManager.self) var languageManager
    @Environment(AppSettings.self) var appSettings
    @Environment(\.modelContext) private var modelContext

    @State private var showTipJar = false
    @State private var onboardingPresentation: OnboardingPresentation?
    @State private var backupViewModel: BackupViewModel?
    @State private var showFileImporter = false

    var onDataImported: ((ImportBackupResult) -> Void)?

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

            backupSection
        }
        .scrollContentBackground(.hidden)
        .background(Color("MainBackground"))
        .task {
            if backupViewModel == nil {
                backupViewModel = AppFactory.makeBackupViewModel(modelContext: modelContext)
            }
        }
        .onChange(of: backupViewModel?.importResult) { _, newValue in
            guard let newValue, newValue.imported > 0 else { return }
            backupViewModel?.importResult = nil
            onDataImported?(newValue)
        }
        .fullScreenCover(item: $onboardingPresentation) { presentation in
            OnboardingView(viewModel: presentation.viewModel)
                .environment(languageManager)
        }
        .fileExporter(
            isPresented: Binding(
                get: { backupViewModel?.pendingExport != nil },
                set: { newValue in
                    if !newValue { backupViewModel?.pendingExport = nil }
                }
            ),
            document: backupViewModel?.pendingExport.map { BackupDocument(data: $0.data) },
            contentType: .json,
            defaultFilename: backupViewModel?.pendingExport?.suggestedFilename
        ) { _ in
            backupViewModel?.pendingExport = nil
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { return }
            backupViewModel?.handleImport(from: url)
        }
        .alert(
            Copies.Backup.importSuccessTitle,
            isPresented: Binding(
                get: { backupViewModel?.importResult != nil },
                set: { newValue in
                    if !newValue { backupViewModel?.importResult = nil }
                }
            ),
            presenting: backupViewModel?.importResult
        ) { _ in
            Button(Copies.Backup.actionOK, role: .cancel) {
                backupViewModel?.importResult = nil
            }
        } message: { result in
            Text(Copies.Backup.importSuccessMessage(imported: result.imported, skipped: result.skipped))
        }
        .alert(
            Copies.ErrorAlert.title,
            isPresented: Binding(
                get: { backupViewModel?.errorMessage != nil },
                set: { newValue in
                    if !newValue { backupViewModel?.errorMessage = nil }
                }
            ),
            presenting: backupViewModel?.errorMessage
        ) { _ in
            Button(Copies.ErrorAlert.dismiss, role: .cancel) {
                backupViewModel?.errorMessage = nil
            }
        } message: { message in
            Text(message)
        }
    }

    @ViewBuilder
    private var backupSection: some View {
        Section {
            Button {
                backupViewModel?.prepareExport()
            } label: {
                Label(Copies.SettingsView.exportBackup, systemImage: "square.and.arrow.up")
                    .foregroundStyle(.primary)
            }
            .disabled(backupViewModel == nil)

            Button {
                showFileImporter = true
            } label: {
                Label(Copies.SettingsView.importBackup, systemImage: "square.and.arrow.down")
                    .foregroundStyle(.primary)
            }
            .disabled(backupViewModel == nil)
        } header: {
            Text(Copies.SettingsView.dataSection)
        } footer: {
            Text(Copies.SettingsView.dataSectionFooter)
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
