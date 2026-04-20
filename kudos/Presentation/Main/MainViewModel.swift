import SwiftUI

enum Mode {
    case edit
    case view
}

@Observable
@MainActor
final class MainViewModel {
    var mode: Mode = .view
    var text: String = ""
    var showSavedMessage: Bool = false
    var selectedPhotoData: Data?
    var showCamera: Bool = false
    var errorMessage: String?
    var accomplishments: [AccomplishmentItem] = []
    var accomplishmentsCount: Int { accomplishments.count }

    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    private let addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol
    private let getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol
    private let deleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol

    init(
        addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol,
        addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol,
        getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol,
        deleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol
    ) {
        self.addAccomplishmentUseCase = addAccomplishmentUseCase
        self.addPhotoAccomplishmentUseCase = addPhotoAccomplishmentUseCase
        self.getAccomplishmentsUseCase = getAccomplishmentsUseCase
        self.deleteAccomplishmentUseCase = deleteAccomplishmentUseCase
    }
    
    func loadAccomplishments() {
          do {
              accomplishments = try getAccomplishmentsUseCase.execute()
          } catch {
              errorMessage = error.localizedDescription
          }
      }

    func cancelEdit() {
        text = ""
        selectedPhotoData = nil
        mode = .view
    }

    func save() {
        do {
            if let photoData = selectedPhotoData {
                let caption = text.trimmingCharacters(in: .whitespacesAndNewlines)
                try addPhotoAccomplishmentUseCase.execute(
                    photoData: photoData,
                    caption: caption.isEmpty ? nil : caption
                )
            } else {
                try addAccomplishmentUseCase.execute(text: text)
            }
            errorMessage = nil
            showSavedMessage = true
            loadAccomplishments()
            text = ""
            selectedPhotoData = nil
            mode = .view
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func delete(_ accomplishment: AccomplishmentItem) {
        do {
            try deleteAccomplishmentUseCase.execute(accomplishment)
            loadAccomplishments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func hideSavedMessage() {
        showSavedMessage = false
    }

    func imageSelected(_ image: UIImage) {
        if let compressedData = CameraHelpers.compressImage(image) {
            selectedPhotoData = compressedData
        }
    }

}
