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
    var accomplishmentsCount: Int = 0
    var accomplishments: [Accomplishment] = []

    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    private let getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol
    
    init(
        addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol,
        getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol
    ) {
        self.addAccomplishmentUseCase = addAccomplishmentUseCase
        self.getAccomplishmentsUseCase = getAccomplishmentsUseCase
    }
    
    func loadAccomplishments() {
          do {
              accomplishments = try getAccomplishmentsUseCase.execute()
              accomplishmentsCount = accomplishments.count
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
            accomplishmentsCount += 1
            
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

    func hideSavedMessage() {
        showSavedMessage = false
    }

}
