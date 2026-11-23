import Combine
import CoreData
import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(LocalizationManager.self) var languageManager
    @State private var viewModel: MainViewModel?
    @State private var selectedTab: Int = 0

    var body: some View {
        let _ = languageManager.currentLanguage
        Group {
            if let viewModel {
                TabView(selection: $selectedTab) {
                    Tab(Copies.homeTab, systemImage: "house.fill", value: 0) {
                        MainView(viewModel: viewModel, onShowMyKudos: { selectedTab = 1 })
                    }

                    Tab(Copies.carouselTab, systemImage: "rectangle.stack.fill", value: 1) {
                        NavigationStack {
                            CarouselView(
                                accomplishments: viewModel.accomplishments,
                                onDelete: { item in viewModel.delete(item) },
                                onEdit: { item, text in viewModel.edit(item, newText: text) },
                                onAddNew: { selectedTab = 0 }
                            )
                            .navigationTitle(Copies.carouselTab)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }

                    Tab(Copies.settingsTitle, systemImage: "gear", value: 2) {
                        NavigationStack {
                            SettingsView(onDataImported: { [weak viewModel] result in
                                viewModel?.didImportBackup(result)
                                selectedTab = 0
                            })
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
        .task {
            guard viewModel == nil else { return }
            let vm = AppFactory.makeMainViewModel(modelContext: modelContext)
            vm.loadAccomplishments()
            viewModel = vm
        }
        // Kudos can arrive from outside this screen: iCloud from other devices
        // or Siri. The list is a snapshot, so reload it when that happens.
        .onReceive(Self.storeChanges) { _ in
            viewModel?.loadAccomplishments()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                viewModel?.loadAccomplishments()
            case .background:
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
        }
    }

    /// Remote changes are posted on background queues and in bursts during an
    /// iCloud import: deliver them on main, once per burst.
    private static let storeChanges = NotificationCenter.default
        .publisher(for: .NSPersistentStoreRemoteChange)
        .merge(with: NotificationCenter.default.publisher(for: .kudosDidChangeExternally))
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
}

extension Notification.Name {
    /// Posted after something outside the main screen (e.g. an App Intent)
    /// saved a kudo in this process.
    static let kudosDidChangeExternally = Notification.Name("kudosDidChangeExternally")
}

#Preview {
    ContentView()
        .modelContainer(for: AccomplishmentEntity.self, inMemory: true)
        .environment(LocalizationManager.shared)
}
