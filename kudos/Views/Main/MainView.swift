import SwiftData
import SwiftUI
import UIKit

public struct MainView: View {
    @State private var viewModel = MainViewModel()
    @Environment(LanguageManager.self) var languageManager
    @State private var selectedImage: UIImage?

    var textAction: (String) -> Void
    var photoAction: (Data, String?) -> Void

    public var body: some View {
        NavigationStack {
            VStack(spacing: Space.extraLarge + Space.medium) {
                KudosJarView()

                HeaderView(mode: $viewModel.mode, text: $viewModel.text)
                    .padding(.top, Space.mediumLarge)

                StickiesViewOverview(
                    mode: $viewModel.mode,
                    text: $viewModel.text,
                    counter: $viewModel.counter,
                    showSaveIndicator: $viewModel.showSaveIndicator,
                    showSavedMessage: $viewModel.showSavedMessage,
                    dragOffset: $viewModel.dragOffset,
                    selectedPhotoData: $viewModel.selectedPhotoData,
                    onShowCamera: {
                        viewModel.showCamera = true
                    },
                    textAction: textAction,
                    photoAction: photoAction,
                    onSave: {
                        viewModel.incrementCounter()
                        viewModel.resetAllInput()
                    }
                )

                Spacer()
                HStack {
                    Button {
                        viewModel.showLanguageSettings = true
                    } label: {
                        HStack {
                            Image(systemName: Icon.settings.rawValue)
                                .foregroundStyle(.white)
                            Text(Copies.setingsTitle)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, Space.small)
                        .padding(.horizontal, Space.medium)
                        .background(Color("PrimaryButtonBackground"))
                        .clipShape(.rect(cornerRadius: CGFloat(Size.extraSmall.rawValue)))
                    }
                    .accessibilityIdentifier(A11y.MainView.settingsIndentifierButton)

                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: Icon.info.rawValue)
                                .foregroundStyle(.white)
                            Text(Copies.aboutTitle)
                                .foregroundStyle(.white)
                        }
                        .padding(.vertical, Space.small)
                        .padding(.horizontal, Space.medium)
                        .background(Color("PrimaryButtonBackground"))
                        .clipShape(.rect(cornerRadius: CGFloat(Size.extraSmall.rawValue)))
                    }
                    .accessibilityLabel(A11y.MainView.aboutLabelButton)
                    .accessibilityHint(A11y.MainView.aboutHintButton)
                    .accessibilityIdentifier(A11y.MainView.aboutIndentifierButton)
                }

            }
            .savedConfirmation(isPresented: $viewModel.showSavedMessage, onDismiss: {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.savedMessageDismissDelay))
                    viewModel.hideSavedMessage()
                }
            })
            .confettiCannon(counter: $viewModel.counter)
            .padding(.horizontal)
            .sheet(isPresented: $viewModel.showLanguageSettings) {
                LanguageSettingsView()
                    .presentationDetents([.height(180)])
            }
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
                    // Compress and store the image
                    if let compressedData = CameraHelpers.compressImage(image) {
                        viewModel.selectedPhotoData = compressedData
                    }
                    selectedImage = nil
                }
            }
            .localized()
            .background(Color("MainBackground"))
        }
    }
}

#if targetEnvironment(simulator)
    #Preview {
        MainView(textAction: { _ in }, photoAction: { _, _ in })
            .environment(LanguageManager.shared)
            .preferredColorScheme(.dark)
    }
#endif
