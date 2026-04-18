protocol GetAccomplishmentsUseCaseProtocol {
    func execute() throws -> [Accomplishment]
}

final class GetAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [Accomplishment] {
        try repository.fetchAllSortedByDateDescending()
    }
}
