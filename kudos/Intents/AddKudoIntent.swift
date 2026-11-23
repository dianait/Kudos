import AppIntents
import Foundation
import WidgetKit

/// "Hey Siri, add a kudo in Kudos": asks for the text and saves it without
/// opening the app. Runs in the app's process, on the app's shared container.
struct AddKudoIntent: AppIntent {
    static let title: LocalizedStringResource = "intent_add_kudo_title"
    static let description = IntentDescription("intent_add_kudo_description")

    @Parameter(title: "intent_add_kudo_text", requestValueDialog: "intent_add_kudo_prompt")
    var text: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try KudosStore.appContainer.get()
        let repository = SwiftDataAccomplishmentRepository(modelContext: container.mainContext)
        // Same rules as the editor (trimming, length limit).
        try AddAccomplishmentUseCase(repository: repository).execute(text: text)

        NotificationCenter.default.post(name: .kudosDidChangeExternally, object: nil)
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "intent_add_kudo_done")
    }
}

struct KudosShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddKudoIntent(),
            phrases: [
                "Add a kudo in \(.applicationName)",
                "Save a kudo in \(.applicationName)",
                "New \(.applicationName)",
            ],
            shortTitle: "intent_add_kudo_title",
            systemImageName: "star.fill"
        )
    }
}
