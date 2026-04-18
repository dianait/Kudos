import SwiftUI

protocol AddPhotoAccomplishmentUseCaseProtocol {
    func execute(photoData: Data, caption: String?) throws
}

final class AddPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(photoData: Data, caption: String?) throws {
        let new = NewAccomplishment(
            text: caption,
            photoData: photoData,
            color: AccomplishmentColor.randomColorString()
        )
        try repository.save(new)
    }
}
