final class GetAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [AccomplishmentItem] {
        try repository.fetchAllSortedByDateDescending()
    }
}
