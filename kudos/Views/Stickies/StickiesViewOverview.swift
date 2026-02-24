import SwiftData
import SwiftUI

struct StickiesViewOverview: View {
    @Environment(LanguageManager.self) var languageManager
    @FocusState private var responseIsFocussed: Bool
    @State private var isEditModeActive: Bool = false
    @State private var characterCount: Int = 0
    @State private var validationError: ValidationError?
    @State private var showValidationError: Bool = false
    private let maxCharacters: Int = Limits.maxCharacters

    @Binding var mode: Mode
    @Binding var text: String
    @Binding var counter: Int
    @Binding var showSaveIndicator: Bool
    @Binding var showSavedMessage: Bool
    @Binding var dragOffset: CGSize
    @Binding var selectedPhotoData: Data?

    var onShowCamera: () -> Void
    var textAction: (String) -> Void
    var photoAction: (Data, String?) -> Void
    var onSave: () -> Void

    /// Whether there is content to save (text or photo)
    private var hasContent: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedPhotoData != nil
    }

    var body: some View {
        ZStack {
            if mode == .edit {
                VStack {
                    ZStack {
                        // Show photo preview if selected, otherwise show sticky background
                        if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                            photoPreviewView(image: uiImage)
                        } else {
                            StickiesView(mode: $mode)
                        }

                        // Text input overlay (only when no photo selected)
                        if selectedPhotoData == nil {
                            textInputView
                        }
                    }

                    // Camera button
                    cameraButton

                    // Save button
                    saveButton
                }
                .offset(dragOffset)
                .simultaneousGesture(
                    DragGesture(minimumDistance: CGFloat(Size.extraSmall.rawValue))
                        .onChanged { gesture in
                            if hasContent {
                                let dragAmount = gesture.translation.height
                                let dampedAmount = min(0, dragAmount * Limits.dragDampingFactor)
                                dragOffset = CGSize(width: 0, height: dampedAmount)
                                showSaveIndicator = dragAmount < Limits.saveIndicatorThreshold

                                if dragAmount < Limits.saveIndicatorThreshold, !showSaveIndicator {
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
                                    save()
                                    withAnimation {
                                        showSavedMessage = true
                                        dragOffset = .zero
                                        showSaveIndicator = false
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
                                    dragOffset = .zero
                                    showSaveIndicator = false
                                }
                            }
                        }
                )
                .accessibilityAction(named: A11y.StickiesViewOverview.saveAction) {
                    if hasContent {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        save()
                        showSavedMessage = true
                    }
                }
            } else {
                StickiesView(mode: $mode)
            }
        }
        .onChange(of: mode) { oldValue, newValue in
            if newValue == .edit && oldValue == .view {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.accessibilityNotificationDelay))
                    responseIsFocussed = true
                }
            }
        }
        .alert(Copies.ValidationAlert.title, isPresented: $showValidationError) {
            Button(Copies.ValidationAlert.okButton, role: .cancel) {
                showValidationError = false
            }
        } message: {
            Text(validationError?.errorDescription ?? Copies.ValidationAlert.defaultMessage)
        }
        .localized()
    }

    private func save() {
        // Check if we have a photo to save
        if let photoData = selectedPhotoData {
            // Save with photo (text is optional caption)
            let caption = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text
            photoAction(photoData, caption)
            characterCount = 0
            onSave()
            mode = .view
            return
        }

        // No photo - validate text before saving
        let validationResult = AccomplishmentValidator.validateText(text)

        switch validationResult {
        case .success(let validatedText):
            textAction(validatedText)
            characterCount = 0
            onSave()
            mode = .view
        case .failure(let error):
            // Validation failed - keep edit mode and show error to user
            validationError = error
            showValidationError = true
            // Keep focus on text editor so user can fix the issue
            responseIsFocussed = true
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var textInputView: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                // Placeholder text - only visible when text is empty
                if text.isEmpty {
                    Text(Copies.StickiesViewOverView.textEditorPlaceHolder)
                        .foregroundStyle(.gray)
                        .font(.body)
                        .padding([.leading, .trailing])
                        .padding(.top, 8)
                        .accessibilityHidden(true)
                }

                // TextEditor - always present but only visible when there's text
                TextEditor(text: $text)
                    .focused($responseIsFocussed)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundStyle(.black)
                    .font(.body)
                    .onChange(of: text) { _, newValue in
                        characterCount = newValue.count

                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                            characterCount = maxCharacters
                        }
                    }
                    .onAppear {
                        characterCount = text.count
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(Timing.focusDelay))
                            responseIsFocussed = true

                            Task { @MainActor in
                                try? await Task.sleep(for: .seconds(Timing.accessibilityNotificationDelay))
                                UIAccessibility.post(
                                    notification: .screenChanged,
                                    argument: A11y.StickiesViewOverview.editModeNotification
                                )
                            }

                            isEditModeActive = true
                        }
                    }
                    .onDisappear {
                        isEditModeActive = false
                    }
                    .onReceive(text.publisher.last()) {
                        if ($0 as Character).asciiValue == 10 {
                            responseIsFocussed = false
                            text.removeLast()
                            characterCount = text.count
                        }
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

            // Remove photo button
            Button {
                withAnimation {
                    selectedPhotoData = nil
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
    private var saveButton: some View {
        Button {
            if hasContent {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.saveActionDelay))
                    save()
                    withAnimation {
                        showSavedMessage = true
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
            onShowCamera()
        } label: {
            HStack(spacing: Space.small) {
                Image(systemName: Icon.camera.rawValue)
                Text(selectedPhotoData == nil ? Copies.Camera.addPhoto : Copies.Camera.changePhoto)
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
