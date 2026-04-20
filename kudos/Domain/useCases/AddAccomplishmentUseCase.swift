import Foundation

final class AddAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String) throws {
        let validatedText = try AccomplishmentValidator.validateText(text)
        let accomplishment = NewAccomplishment(
            text: validatedText,
            photoData: nil,
            color: AccomplishmentColor.randomColorString(),
            date: Date()
        )
        try repository.save(accomplishment)
    }
}
