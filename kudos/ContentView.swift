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
                        WrappedView()
                    }

                    Tab(Copies.setingsTitle, systemImage: "gear") {
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
            let vm = MainViewModelFactory.make(modelContext: modelContext)
            vm.loadAccomplishments()
            viewModel = vm
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
        .environment(LanguageManager.shared)
}

enum MainViewModelFactory {
    static func make(modelContext: ModelContext) -> MainViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)
        let addAccomplishmentUseCase = AddAccomplishmentUseCase(repository: repository)
        let addPhotoAccomplishmentUseCase = AddPhotoAccomplishmentUseCase(repository: repository)
        let getAccomplishmentsUseCase = GetAccomplishmentsUseCase(repository: repository)
        let deleteAccomplishmentUseCase = DeleteAccomplishmentUseCase(repository: repository)

        return MainViewModel(
            addAccomplishmentUseCase: addAccomplishmentUseCase,
            addPhotoAccomplishmentUseCase: addPhotoAccomplishmentUseCase,
            getAccomplishmentsUseCase: getAccomplishmentsUseCase,
            deleteAccomplishmentUseCase: deleteAccomplishmentUseCase
        )
    }
}
