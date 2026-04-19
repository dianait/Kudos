import Testing
import Foundation
@testable import kudos

@Suite("GetAccomplishmentsUseCase Tests")
struct GetAccomplishmentsUseCaseTests {

    @Test("Returns items from repository")
    func returnsItemsFromRepository() throws {
        let items = [makeItem(text: "Logro 1"), makeItem(text: "Logro 2")]
        let sut = GetAccomplishmentsUseCase(repository: StubAccomplishmentRepository(items: items))

        let result = try sut.execute()

        #expect(result.count == 2)
        #expect(result[0].text == "Logro 1")
        #expect(result[1].text == "Logro 2")
    }

    @Test("Returns empty array when repository has no items")
    func returnsEmptyWhenRepositoryIsEmpty() throws {
        let sut = GetAccomplishmentsUseCase(repository: StubAccomplishmentRepository(items: []))

        let result = try sut.execute()

        #expect(result.isEmpty)
    }

    @Test("Propagates error thrown by repository")
    func propagatesRepositoryError() {
        let sut = GetAccomplishmentsUseCase(repository: StubAccomplishmentRepository(shouldThrow: true))

        #expect(throws: (any Error).self) {
            try sut.execute()
        }
    }
}

private func makeItem(text: String = "Logro") -> AccomplishmentItem {
    AccomplishmentItem(id: UUID().uuidString, date: Date(), text: text, colorHex: "blue", photoData: nil)
}

private final class StubAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let items: [AccomplishmentItem]
    private let shouldThrow: Bool

    init(items: [AccomplishmentItem] = [], shouldThrow: Bool = false) {
        self.items = items
        self.shouldThrow = shouldThrow
    }

    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] {
        if shouldThrow { throw TestError.generic }
        return items
    }

    func save(_ accomplishment: NewAccomplishment) throws {}
    func delete(_ accomplishment: AccomplishmentItem) throws {}
}

private enum TestError: Error { case generic }
