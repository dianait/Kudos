protocol AddAccomplishmentUseCaseProtocol {
    func execute(text: String) throws
}
final class AddAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol {
    let repository: AccomplishmentRepositoryProtocol
    
    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(text: String) throws {
        let validatedText = try AccomplishmentValidatorNew.validateText(text)
        let accomplishment = NewAccomplishment(text: validatedText)
        try repository.save(accomplishment)
    }
}
