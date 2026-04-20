import SwiftUI

struct StickiesViewOverview: View {
    @Bindable var viewModel: MainViewModel
    @Environment(LanguageManager.self) var languageManager
    @FocusState private var responseIsFocussed: Bool
    private let maxCharacters: Int = Limits.maxCharacters
    private var characterCount: Int { viewModel.text.count }

    private var textBinding: Binding<String> {
        Binding(
            get: { viewModel.text },
            set: { newValue in
                if newValue.last == "\n" {
                    responseIsFocussed = false
                    viewModel.text = String(newValue.dropLast().prefix(maxCharacters))
                } else {
                    viewModel.text = String(newValue.prefix(maxCharacters))
                }
            }
        )
    }
    private var lastItem: AccomplishmentItem? {
        viewModel.accomplishments.first
    }
    
    private var previewImage: UIImage? {
        viewModel.selectedPhotoData.flatMap { UIImage(data: $0) }
    }

    private var hasContent: Bool {
        !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.selectedPhotoData != nil
    }

    var body: some View {
        ZStack {
            if viewModel.mode == .edit {
                VStack {
                    ZStack {
                        if let previewImage {
                            photoPreviewView(image: previewImage)
                        } else {
                            StickiesView(lastItem: lastItem, mode: $viewModel.mode)
                        }
                        if viewModel.selectedPhotoData == nil {
                            textInputView
                        }
                    }
                    cameraButton
                    HStack(spacing: Space.medium) {
                        cancelButton
                        saveButton
                    }
                }
                .offset(viewModel.dragOffset)
                .simultaneousGesture(
                    DragGesture(minimumDistance: CGFloat(Size.extraSmall.rawValue))
                        .onChanged { gesture in
                            if hasContent {
                                let dragAmount = gesture.translation.height
                                let dampedAmount = min(0, dragAmount * Limits.dragDampingFactor)
                                viewModel.dragOffset = CGSize(width: 0, height: dampedAmount)
                                viewModel.showSaveIndicator = dragAmount < Limits.saveIndicatorThreshold

                                if dragAmount < Limits.saveIndicatorThreshold, !viewModel.showSaveIndicator {
                                    UIAccessibility.post(
                                        notification: .announcement,
                                        argument: A11y.StickiesViewOverview.readyToSaveNotification
                                    )
                                }
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.height < Limits.saveDragThreshold, hasContent {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                Task { @MainActor in
                                    try? await Task.sleep(for: .seconds(Timing.saveActionDelay))
                                    viewModel.save()
                                    withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
                                        viewModel.dragOffset = .zero
                                        viewModel.showSaveIndicator = false
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
                                    viewModel.dragOffset = .zero
                                    viewModel.showSaveIndicator = false
                                }
                            }
                        }
                )
                .accessibilityAction(named: A11y.StickiesViewOverview.saveAction) {
                    if hasContent {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        viewModel.save()
                    }
                }
            } else {
                StickiesView(lastItem: lastItem, mode: $viewModel.mode)
            }
        }
        .onChange(of: viewModel.mode) { oldValue, newValue in
            if newValue == .edit && oldValue == .view {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.accessibilityNotificationDelay))
                    responseIsFocussed = true
                }
            }
        }
        .localized()
    }

    // MARK: - Subviews

    @ViewBuilder
    private var textInputView: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                if viewModel.text.isEmpty {
                    Text(Copies.StickiesViewOverView.textEditorPlaceHolder)
                        .foregroundStyle(.gray)
                        .font(.body)
                        .padding([.leading, .trailing])
                        .padding(.top, 8)
                        .accessibilityHidden(true)
                }

                TextEditor(text: textBinding)
                    .focused($responseIsFocussed)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundStyle(.black)
                    .font(.body)
                    .task {
                        try? await Task.sleep(for: .seconds(Timing.focusDelay))
                        responseIsFocussed = true
                        try? await Task.sleep(for: .seconds(Timing.accessibilityNotificationDelay))
                        UIAccessibility.post(
                            notification: .screenChanged,
                            argument: A11y.StickiesViewOverview.editModeNotification
                        )
                    }
                    .padding([.leading, .trailing])
                    .frame(width: Dimensions.textEditorWidth, height: Dimensions.textEditorHeight)
                    .accessibilityLabel(A11y.StickiesViewOverview.textEditorLabel)
                    .accessibilityHint(A11y.StickiesViewOverview.textEditorHint)
                    .accessibilityIdentifier(A11y.StickiesViewOverview.textEditorIdentifer)
            }

            Text("\(characterCount)/\(maxCharacters)")
                .font(.caption)
                .foregroundStyle(characterCount > maxCharacters ? .red : .gray)
                .frame(width: Dimensions.counterFrameWidth, alignment: .trailing)
                .padding(.trailing)
                .accessibilityLabel(
                    A11y.StickiesViewOverview.charCounterLabel(
                        count: characterCount,
                        max: maxCharacters
                    )
                )
        }
    }

    @ViewBuilder
    private func photoPreviewView(image: UIImage) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: Dimensions.stickyWidth, height: Dimensions.stickyHeight)
                .clipShape(RoundedRectangle(cornerRadius: CGFloat(Size.small.rawValue)))
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)

            Button {
                withAnimation {
                    viewModel.selectedPhotoData = nil
                }
            } label: {
                Image(systemName: Icon.xmark.rawValue)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)).frame(width: 30, height: 30))
            }
            .padding(8)
            .accessibilityLabel(Copies.Camera.removePhoto)
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        Button {
            responseIsFocussed = false
            viewModel.cancelEdit()
        } label: {
            HStack(spacing: Space.small) {
                Image(systemName: Icon.xmark.rawValue)
                Text(Copies.StickiesViewOverView.cancelButton)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, Space.medium)
            .padding(.vertical, Space.small)
            .background(Capsule().fill(Color.gray.opacity(0.7)))
        }
        .padding(.top, Space.extraSmall)
        .accessibilityIdentifier(A11y.StickiesViewOverview.cancelButtonIdentifier)
    }

    @ViewBuilder
    private var saveButton: some View {
        Button {
            if hasContent {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.saveActionDelay))
                    viewModel.save()
                    withAnimation {
                        viewModel.dragOffset = .zero
                        viewModel.showSaveIndicator = false
                    }
                }
            }
        } label: {
            HStack(spacing: Space.small) {
                Image(systemName: Icon.checkmark.rawValue)
                Text(Copies.StickiesViewOverView.saveButton)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, Space.medium)
            .padding(.vertical, Space.small)
            .background(Capsule().fill(hasContent ? Color.green : Color.gray))
        }
        .disabled(!hasContent)
        .padding(.top, Space.extraSmall)
        .accessibilityLabel(A11y.StickiesViewOverview.saveButtonLabel)
        .accessibilityHint(A11y.StickiesViewOverview.saveButtonHint)
        .accessibilityIdentifier(A11y.StickiesViewOverview.saveButtonIdentifier)
    }

    @ViewBuilder
    private var cameraButton: some View {
        Button {
            viewModel.showCamera.toggle()
        } label: {
            HStack(spacing: Space.small) {
                Image(systemName: Icon.camera.rawValue)
                Text(viewModel.selectedPhotoData == nil ? Copies.Camera.addPhoto : Copies.Camera.changePhoto)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, Space.medium)
            .padding(.vertical, Space.small)
            .background(Capsule().fill(Color.orange))
        }
        .padding(.top, Space.small)
        .accessibilityLabel(Copies.Camera.addPhoto)
        .accessibilityHint(Copies.Camera.addPhotoHint)
    }
}
