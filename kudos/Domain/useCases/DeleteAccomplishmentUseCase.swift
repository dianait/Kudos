protocol DeleteAccomplishmentUseCaseProtocol {
    func execute(_ accomplishment: Accomplishment) throws
}

final class DeleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ accomplishment: Accomplishment) throws {
        try repository.delete(accomplishment)
    }
}
