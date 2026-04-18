import SwiftUI

public enum Mode {
    case edit
    case view
}

@Observable
public final class MainViewModel {
    var mode: Mode = .view
    var text: String = ""
    var showSaveIndicator: Bool = false
    var showSavedMessage: Bool = false
    var dragOffset: CGSize = .zero
    var selectedPhotoData: Data?
    var showCamera: Bool = false
    var errorMessage: String?
    var accomplishments: [Accomplishment] = []
    var accomplishmentsCount: Int { accomplishments.count }

    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    private let getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol
    private let deleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol
    
    init(
        addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol,
        getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol,
        deleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol
    ) {
        self.addAccomplishmentUseCase = addAccomplishmentUseCase
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

    func save() {
        guard selectedPhotoData == nil else { return }
        do {
            try addAccomplishmentUseCase.execute(text: text)
            errorMessage = nil
            showSavedMessage = true
        
            loadAccomplishments()
            
            text = ""
            selectedPhotoData = nil
            mode = .view
            dragOffset = .zero
            showSaveIndicator = false

        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func delete(_ accomplishment: Accomplishment) {
        do {
            print("Deleting:", accomplishment)
            try deleteAccomplishmentUseCase.execute(accomplishment)
            loadAccomplishments()
        } catch {
            errorMessage = error.localizedDescription
            print("Delete error:", error)
        }
    }

    func hideSavedMessage() {
        showSavedMessage = false
    }

}
