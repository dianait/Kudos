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

    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    private let getAccomplishmentCountUseCase: GetAccomplishmentCountUseCaseProtocol
    
    init(addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol,
         getAccomplishmentCountUseCase: GetAccomplishmentCountUseCaseProtocol) {
           self.addAccomplishmentUseCase = addAccomplishmentUseCase
           self.getAccomplishmentCountUseCase = getAccomplishmentCountUseCase
       }
    
    func loadAccomplishmentsCount() {
         do {
             accomplishmentsCount = try getAccomplishmentCountUseCase.execute()
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
