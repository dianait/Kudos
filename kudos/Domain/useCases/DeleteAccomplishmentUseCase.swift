final class DeleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ accomplishment: AccomplishmentItem) throws {
        try repository.delete(accomplishment)
    }
}
