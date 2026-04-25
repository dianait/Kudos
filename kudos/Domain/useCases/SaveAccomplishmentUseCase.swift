import Foundation

@MainActor
final class SaveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol {
    private let addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol
    private let addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol

    init(
        addAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol,
        addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol
    ) {
        self.addAccomplishmentUseCase = addAccomplishmentUseCase
        self.addPhotoAccomplishmentUseCase = addPhotoAccomplishmentUseCase
    }

    func execute(text: String, photoData: Data?) throws {
        if let photoData {
            try addPhotoAccomplishmentUseCase.execute(photoData: photoData, caption: text)
        } else {
            try addAccomplishmentUseCase.execute(text: text)
        }
    }
}
