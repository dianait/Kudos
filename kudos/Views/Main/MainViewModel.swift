import SwiftUI
import Observation

public enum Mode {
    case edit
    case view
}

@Observable

public final class MainViewModel {

    var mode: Mode = .view
    var text: String = ""
    var counter: Int = 0
    var showSaveIndicator: Bool = false
    var showSavedMessage: Bool = false
    var dragOffset: CGSize = .zero
    var selectedPhotoData: Data?
    var showCamera: Bool = false
    var errorMessage: String?

    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    
    init(addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol) {
        self.addAccomplishmentUseCase = addAccomplishmentUseCase
    }

    func save() {
        guard selectedPhotoData == nil else { return }
        do {
            try addAccomplishmentUseCase.execute(text: text)
            errorMessage = nil
            showSavedMessage = true
            counter += 1
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
