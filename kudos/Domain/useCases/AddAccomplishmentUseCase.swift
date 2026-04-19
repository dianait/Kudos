final class AddAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol {
    let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(text: String, color: String) throws {
        let validatedText = try AccomplishmentValidator.validateText(text)
        let accomplishment = NewAccomplishment(
            text: validatedText,
            photoData: nil,
            color: color
        )
        try repository.save(accomplishment)
    }
}
