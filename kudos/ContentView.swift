import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager
    @State private var viewModel: MainViewModel?

    var body: some View {
        let language = languageManager.currentLanguage
        Group {
            if let viewModel {
                TabView {
                    Tab(Copies.homeTab, systemImage: "house.fill") {
                        MainView(viewModel: viewModel)
                    }

                    Tab(Copies.carouselTab, systemImage: "rectangle.stack.fill") {
                        NavigationStack {
                            CarouselView(
                                accomplishments: viewModel.accomplishments,
                                onDelete: { item in viewModel.delete(item) }
                            )
                            .navigationTitle(Copies.carouselTab)
                            .navigationBarTitleDisplayMode(.inline)
                        }
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
            } else {
                ProgressView()
            }
        }
        .id(language)
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
