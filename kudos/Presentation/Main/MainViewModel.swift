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
    var showImportedMessage: Bool = false
    var lastImportResult: ImportBackupResult?
    var selectedPhotoData: Data?
    var showCamera: Bool = false
    var errorMessage: String?
    var accomplishments: [AccomplishmentItem] = []
    var accomplishmentsCount: Int { accomplishments.count }

    private let saveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol
    private let editAccomplishmentUseCase: EditAccomplishmentUseCaseProtocol
    private let repository: AccomplishmentRepositoryProtocol

    init(
        saveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol,
        editAccomplishmentUseCase: EditAccomplishmentUseCaseProtocol,
        repository: AccomplishmentRepositoryProtocol
    ) {
        self.saveAccomplishmentUseCase = saveAccomplishmentUseCase
        self.editAccomplishmentUseCase = editAccomplishmentUseCase
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
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty || selectedPhotoData != nil else { return }

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
    
    /// Returns true when the new text was stored, so the editor can close.
    @discardableResult
    func edit(_ accomplishment: AccomplishmentItem, newText: String) -> Bool {
        do {
            try editAccomplishmentUseCase.execute(item: accomplishment, newText: newText)
            loadAccomplishments()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
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

    func didImportBackup(_ result: ImportBackupResult) {
        lastImportResult = result
        showImportedMessage = true
        loadAccomplishments()
    }

    func hideImportedMessage() {
        showImportedMessage = false
        lastImportResult = nil
    }

    /// Photo picked from the library: downsampled and re-encoded off the main
    /// thread (also strips metadata such as GPS location).
    func photoPicked(_ data: Data) async {
        let sanitized = await Task.detached(priority: .userInitiated) {
            PhotoSanitizer.sanitize(data)
        }.value
        if let sanitized {
            selectedPhotoData = sanitized
        } else {
            errorMessage = Copies.Camera.photoLoadFailed
        }
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
