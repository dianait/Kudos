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
                        MainView(
                            viewModel: viewModel,
                            photoAction: addPhotoItem
                        )
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

    private func addPhotoItem(photoData: Data, caption: String?) {
        do {
            let newItem = try Accomplishment(photoData: photoData, text: caption)
            modelContext.insert(newItem)
        } catch {
            print("Error creating photo Accomplishment: \(error.localizedDescription)")
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
        let getAccomplishmentsUseCase = GetAccomplishmentsUseCase(repository: repository)

        return MainViewModel(
            addAccomplishmentUseCase: addAccomplishmentUseCase,
            getAccomplishmentsUseCase: getAccomplishmentsUseCase
        )
    }
}
