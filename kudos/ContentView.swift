import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager

    var body: some View {
        TabView {
            Tab(Copies.homeTab, systemImage: "house.fill") {
                MainView(
                    textAction: addTextItem,
                    photoAction: addPhotoItem
                )
            }

            Tab(Copies.Wrapped.button, systemImage: "sparkles") {
                WrappedView()
            }

            Tab(Copies.setingsTitle, systemImage: "gear") {
                NavigationStack {
                    LanguageSettingsView()
                        .navigationTitle(Copies.setingsTitle)
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

    private func addTextItem(text: String) {
        let validationResult = AccomplishmentValidator.validateText(text)

        switch validationResult {
        case .success(let validatedText):
            do {
                let newItem = try Accomplishment(validatedText)
                modelContext.insert(newItem)
            } catch {
                print("Error creating Accomplishment: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("Validation error: \(error.localizedDescription)")
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
