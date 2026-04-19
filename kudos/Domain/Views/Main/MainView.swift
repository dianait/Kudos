import SwiftUI
import UIKit

public struct MainView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(LanguageManager.self) var languageManager
    @State private var selectedImage: UIImage?
    @State private var confettiCounter: Int = 0

    public init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
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
            .onChange(of: viewModel.accomplishmentsCount) { _, newValue in
                confettiCounter = newValue
            }
            .onAppear {
                confettiCounter = viewModel.accomplishmentsCount
            }
            .background(Color("MainBackground"))
        }
    }
}
