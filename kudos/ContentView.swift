import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) var languageManager
    @Query private var items: [Accomplishment]

    var body: some View {
        MainView(
            textAction: { text in
                addTextItem(text: text)
            },
            photoAction: { photoData, caption in
                addPhotoItem(photoData: photoData, caption: caption)
            }
        )
    }

    private func addTextItem(text: String) {
        // Validate before creating Accomplishment
        let validationResult = AccomplishmentValidator.validateText(text)

        switch validationResult {
        case .success(let validatedText):
            do {
                let newItem = try Accomplishment(validatedText)
                modelContext.insert(newItem)
            } catch {
                // Log error but don't crash - validation should have caught this
                print("Error creating Accomplishment: \(error.localizedDescription)")
            }
        case .failure(let error):
            // Validation failed - log error
            print("Validation error: \(error.localizedDescription)")
        }
    }

    private func addPhotoItem(photoData: Data, caption: String?) {
        do {
            let newItem = try Accomplishment(photoData: photoData, text: caption)
            modelContext.insert(newItem)
        } catch {
            // Log error but don't crash
            print("Error creating photo Accomplishment: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
        .environment(LanguageManager.shared)
}
