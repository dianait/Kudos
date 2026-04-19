import Foundation

final class AddPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(photoData: Data, caption: String?, color: String) throws {
        let validatedCaption: String? = try caption.flatMap { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return try AccomplishmentValidator.validateText(trimmed)
        }
        let new = NewAccomplishment(
            text: validatedCaption,
            photoData: photoData,
            color: color
        )
        try repository.save(new)
    }
}
