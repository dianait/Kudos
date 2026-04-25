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

    private let saveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol
    private let repository: AccomplishmentRepositoryProtocol

    init(
        saveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol,
        repository: AccomplishmentRepositoryProtocol
    ) {
        self.saveAccomplishmentUseCase = saveAccomplishmentUseCase
        self.repository = repository
    }
    
    func loadAccomplishments() {
          do {
              accomplishments = try repository.fetchAllSortedByDateDescending()
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
            try saveAccomplishmentUseCase.execute(text: text, photoData: selectedPhotoData)
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
            try repository.delete(accomplishment)
            loadAccomplishments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func hideSavedMessage() {
        showSavedMessage = false
    }

    func imageSelected(_ image: UIImage) {
        Task {
            let compressed = await Task.detached(priority: .userInitiated) {
                CameraHelpers.compressImage(image)
            }.value
            selectedPhotoData = compressed
        }
    }

}
