import SwiftUI
import UIKit

struct MainView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(LocalizationManager.self) var languageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedImage: UIImage?
    @State private var confettiCounter: Int = 0
    let onShowMyKudos: () -> Void
    private static let isUITesting = CommandLine.arguments.contains("-UITesting")

    init(viewModel: MainViewModel, onShowMyKudos: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onShowMyKudos = onShowMyKudos
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Space.extraLarge + Space.medium) {
                KudosJarView(
                    accomplishments: viewModel.accomplishments,
                    onTap: onShowMyKudos
                )
                HeaderView(mode: $viewModel.mode, text: $viewModel.text)
                    .padding(.top, Space.mediumLarge)

                StickiesViewOverview(viewModel: viewModel)
                Spacer()
            }
            .savedConfirmation(isPresented: $viewModel.showSavedMessage, onDismiss: {
                Task {
                    try? await Task.sleep(for: .seconds(Timing.savedMessageDismissDelay))
                    viewModel.hideSavedMessage()
                }
            })
            .importedConfirmation(
                isPresented: $viewModel.showImportedMessage,
                title: Copies.Backup.importedConfirmationTitle,
                description: Copies.Backup.importedConfirmationDescription(
                    imported: viewModel.lastImportResult?.imported ?? 0,
                    skipped: viewModel.lastImportResult?.skipped ?? 0
                ),
                onDismiss: { viewModel.hideImportedMessage() }
            )
            .confettiCannon(counter: $confettiCounter)
            .padding(.horizontal)
            .sheet(isPresented: $viewModel.showCamera) {
                if CameraHelpers.isCameraAvailable() {
                    CameraPickerView(selectedImage: $selectedImage)
                } else {
                    Text(Copies.Camera.notAvailable)
                        .padding()
                }
            }
            .onChange(of: selectedImage) { _, newImage in
                if let image = newImage {
                    viewModel.imageSelected(image)
                    selectedImage = nil
                }
            }
            .onChange(of: viewModel.accomplishmentsCount) { oldValue, newValue in
                // Confetti uses a repeatForever animation, which keeps the app
                // from going idle and blocks XCUITest queries: skip it in UI tests.
                if newValue > oldValue && !reduceMotion && !Self.isUITesting {
                    confettiCounter += 1
                }
            }
            .alert(Copies.ErrorAlert.title, isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button(Copies.ErrorAlert.dismiss) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .background(Color("MainBackground"))
        }
    }
}
