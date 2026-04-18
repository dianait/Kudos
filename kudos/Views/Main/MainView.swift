import SwiftUI
import UIKit

public struct MainView: View {
    @Bindable var viewModel: MainViewModel
    @Environment(LanguageManager.self) var languageManager
    @State private var selectedImage: UIImage?

    var photoAction: (Data, String?) -> Void
    
    public init(
        viewModel: MainViewModel,
        photoAction: @escaping (Data, String?) -> Void
    ) {
        self.viewModel = viewModel
        self.photoAction = photoAction

    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: Space.extraLarge + Space.medium) {
                KudosJarView(accomplishments: viewModel.accomplishments) { item in
                    viewModel.delete(item)
                }
                HeaderView(mode: $viewModel.mode, text: $viewModel.text)
                    .padding(.top, Space.mediumLarge)

                StickiesViewOverview(
                    viewModel: viewModel,
                    photoAction: photoAction,
                )
                Spacer()
            }
            .savedConfirmation(isPresented: $viewModel.showSavedMessage, onDismiss: {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.savedMessageDismissDelay))
                    viewModel.hideSavedMessage()
                }
            })
            .confettiCannon(counter: $viewModel.accomplishmentsCount)
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
                    if let compressedData = CameraHelpers.compressImage(image) {
                        viewModel.selectedPhotoData = compressedData
                    }
                    selectedImage = nil
                }
            }
            .background(Color("MainBackground"))
        }
    }
}
