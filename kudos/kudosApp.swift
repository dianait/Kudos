import SwiftData
import SwiftUI
import UIKit

@main
struct KudosApp: App {
    @State private var languageManager = LocalizationManager.shared
    @State private var appSettings = AppSettings.shared
    @State private var modelContainerError: Error?
    @State private var modelContainer: ModelContainer?
    @State private var isUsingInMemoryFallback: Bool = false
    @State private var showInMemoryWarning: Bool = false

    private static let isUITesting = CommandLine.arguments.contains("-UITesting")

    init() {
        let schema = KudosStore.schema
        let isUITesting = Self.isUITesting
        if isUITesting {
            // UI tests wait for the app to be idle: animations only slow them down.
            UIView.setAnimationsEnabled(false)
        }

        do {
            let container: ModelContainer
            if isUITesting {
                let configuration = ModelConfiguration(
                    schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
                container = try ModelContainer(for: schema, configurations: [configuration])
            } else {
                // Shared with App Intents (Siri), which can run in this process.
                container = try KudosStore.appContainer.get()
            }
            _modelContainer = State(initialValue: container)
            _isUsingInMemoryFallback = State(initialValue: false)
        } catch {
            // Instead of fatalError, save the error and use an in-memory container as fallback
            print("Error creating ModelContainer: \(error.localizedDescription)")
            _modelContainerError = State(initialValue: error)
            // Try to create an in-memory container as fallback
            do {
                let fallbackConfiguration = ModelConfiguration(
                    schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
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
            if let modelContainer {
                RootView()
                    .background(Color("MainBackground"))
                    .environment(languageManager)
                    .environment(appSettings)
                    .modelContainer(modelContainer)
                    .preferredColorScheme(appSettings.colorSchemePreference.colorScheme)
                    .transaction { transaction in
                        if Self.isUITesting { transaction.disablesAnimations = true }
                    }
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
