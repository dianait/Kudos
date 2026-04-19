import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager
    @State private var viewModel: MainViewModel?

    var body: some View {
        Group {
            if let viewModel {
                TabView {
                    Tab(Copies.homeTab, systemImage: "house.fill") {
                        MainView(viewModel: viewModel)
                    }

                    Tab(Copies.Wrapped.button, systemImage: "sparkles") {
                        WrappedView(viewModel: AppFactory.makeWrappedViewModel(modelContext: modelContext))
                    }

                    Tab(Copies.settingsTitle, systemImage: "gear") {
                        NavigationStack {
                            SettingsView()
                        }
                    }

                    Tab(Copies.aboutTitle, systemImage: "info.circle") {
                        NavigationStack {
                            AboutView()
                        }
                    }
                }
                .localized()
            } else {
                ProgressView()
            }
        }
        .task {
            guard viewModel == nil else { return }
            let vm = AppFactory.makeMainViewModel(modelContext: modelContext)
            vm.loadAccomplishments()
            viewModel = vm
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: AccomplishmentEntity.self, inMemory: true)
        .environment(LanguageManager.shared)
}
