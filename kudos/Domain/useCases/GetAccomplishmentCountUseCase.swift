
protocol GetAccomplishmentCountUseCaseProtocol {
    func execute() throws -> Int
}

final class GetAccomplishmentCountUseCase: GetAccomplishmentCountUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> Int {
        try repository.count()
    }
}
