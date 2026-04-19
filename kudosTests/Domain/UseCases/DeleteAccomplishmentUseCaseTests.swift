import Testing
import Foundation
@testable import kudos

@Suite("DeleteAccomplishmentUseCase Tests")
struct DeleteAccomplishmentUseCaseTests {

    @Test("Delegates delete to repository with the given accomplishment")
    func delegatesDeleteToRepository() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = DeleteAccomplishmentUseCase(repository: repository)
        let item = makeItem()

        try sut.execute(item)

        #expect(repository.deletedAccomplishment?.id == item.id)
    }

    @Test("Propagates error thrown by repository")
    func propagatesRepositoryError() {
        let repository = SpyAccomplishmentRepository(shouldThrowOnDelete: true)
        let sut = DeleteAccomplishmentUseCase(repository: repository)

        #expect(throws: (any Error).self) {
            try sut.execute(makeItem())
        }
    }
}

private func makeItem() -> AccomplishmentItem {
    AccomplishmentItem(id: UUID().uuidString, date: Date(), text: "Logro", colorHex: "blue", photoData: nil)
}

private final class SpyAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    var deletedAccomplishment: AccomplishmentItem?
    private let shouldThrowOnDelete: Bool

    init(shouldThrowOnDelete: Bool = false) {
        self.shouldThrowOnDelete = shouldThrowOnDelete
    }

    func delete(_ accomplishment: AccomplishmentItem) throws {
        if shouldThrowOnDelete { throw TestError.generic }
        deletedAccomplishment = accomplishment
    }

    func save(_ accomplishment: NewAccomplishment) throws {}
    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] { [] }
}

private enum TestError: Error { case generic }
