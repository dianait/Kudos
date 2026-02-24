import SwiftData
import SwiftUI

@main
struct KudosApp: App {
    @State private var languageManager = LanguageManager.shared
    @State private var appSettings = AppSettings.shared
    @State private var modelContainerError: Error?
    @State private var modelContainer: ModelContainer?
    @State private var isUsingInMemoryFallback: Bool = false
    @State private var showInMemoryWarning: Bool = false

    init() {
        // Initialize ModelContainer safely
        let schema = Schema([
            Accomplishment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            _modelContainer = State(initialValue: try ModelContainer(for: schema, configurations: [modelConfiguration]))
            _isUsingInMemoryFallback = State(initialValue: false)
        } catch {
            // Instead of fatalError, save the error and use an in-memory container as fallback
            print("Error creating ModelContainer: \(error.localizedDescription)")
            _modelContainerError = State(initialValue: error)
            // Try to create an in-memory container as fallback
            do {
                let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                _modelContainer = State(initialValue: try ModelContainer(for: schema, configurations: [fallbackConfiguration]))
                _isUsingInMemoryFallback = State(initialValue: true)
                _showInMemoryWarning = State(initialValue: true)
                print("Using in-memory ModelContainer as fallback")
            } catch {
                print("Error creating fallback ModelContainer: \(error.localizedDescription)")
                _modelContainer = State(initialValue: nil)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                ContentView()
                    .background(Color("MainBackground"))
                    .environment(languageManager)
                    .environment(appSettings)
                    .modelContainer(container)
                    .preferredColorScheme(appSettings.colorSchemePreference.colorScheme)
                    .alert(Copies.InMemoryWarning.title, isPresented: $showInMemoryWarning) {
                        Button(Copies.InMemoryWarning.okButton, role: .cancel) {
                            showInMemoryWarning = false
                        }
                    } message: {
                        Text(Copies.InMemoryWarning.message)
                    }
            } else {
                ErrorView(error: modelContainerError)
                    .environment(languageManager)
                    .environment(appSettings)
                    .preferredColorScheme(appSettings.colorSchemePreference.colorScheme)
            }
        }
    }
}
