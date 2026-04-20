import SwiftUI
import UIKit

struct MainView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(LanguageManager.self) var languageManager
    @State private var selectedImage: UIImage?
    @State private var confettiCounter: Int = 0

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Space.extraLarge + Space.medium) {
                KudosJarView(accomplishments: viewModel.accomplishments) { item in
                    viewModel.delete(item)
                }
                HeaderView(mode: $viewModel.mode, text: $viewModel.text)
                    .padding(.top, Space.mediumLarge)

                StickiesViewOverview(viewModel: viewModel)
                Spacer()
            }
            .savedConfirmation(isPresented: $viewModel.showSavedMessage, onDismiss: {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.savedMessageDismissDelay))
                    viewModel.hideSavedMessage()
                }
            })
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
                if newValue > oldValue {
                    confettiCounter += 1
                }
            }
            .background(Color("MainBackground"))
        }
    }
}
