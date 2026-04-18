import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager
   
    var body: some View {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)
        let useCase = AddAccomplishmentUseCase(repository: repository)
        let viewModel = MainViewModel(addAccomplishmentUseCase: useCase)

        let _ = languageManager.currentLanguage
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
