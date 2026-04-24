import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager
    @State private var viewModel: MainViewModel?
    @State private var selectedTab: Int = 0

    var body: some View {
        let language = languageManager.currentLanguage
        Group {
            if let viewModel {
                TabView(selection: $selectedTab) {
                    Tab(Copies.homeTab, systemImage: "house.fill", value: 0) {
                        MainView(viewModel: viewModel)
                    }

                    Tab(Copies.carouselTab, systemImage: "rectangle.stack.fill", value: 1) {
                        NavigationStack {
                            CarouselView(
                                accomplishments: viewModel.accomplishments,
                                onDelete: { item in viewModel.delete(item) },
                                onAddNew: { selectedTab = 0 }
                            )
                            .navigationTitle(Copies.carouselTab)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }

                    Tab(Copies.settingsTitle, systemImage: "gear", value: 2) {
                        NavigationStack {
                            SettingsView()
                        }
                    }

                    Tab(Copies.aboutTitle, systemImage: "info.circle", value: 3) {
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
