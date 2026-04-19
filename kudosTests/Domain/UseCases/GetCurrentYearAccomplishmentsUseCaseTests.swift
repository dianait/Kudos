import Testing
import Foundation
@testable import kudos

@Suite("GetCurrentYearAccomplishmentsUseCase Tests")
struct GetCurrentYearAccomplishmentsUseCaseTests {

    private func makeItem(year: Int) -> AccomplishmentItem {
        var components = DateComponents()
        components.year = year
        components.month = 6
        components.day = 15
        let date = Calendar.current.date(from: components)!
        return AccomplishmentItem(id: UUID().uuidString, date: date, text: "Logro \(year)", colorHex: "blue", photoData: nil)
    }

    @Test("Returns only items from the current year")
    func returnsOnlyCurrentYearItems() throws {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentItem = makeItem(year: currentYear)
        let pastItem = makeItem(year: currentYear - 1)
        let repository = MockAccomplishmentRepository(items: [currentItem, pastItem])
        let sut = GetCurrentYearAccomplishmentsUseCase(repository: repository)

        let result = try sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == currentItem.id)
    }

    @Test("Returns empty when no items match current year")
    func returnsEmptyWhenNoCurrentYearItems() throws {
        let currentYear = Calendar.current.component(.year, from: Date())
        let pastItem = makeItem(year: currentYear - 1)
        let repository = MockAccomplishmentRepository(items: [pastItem])
        let sut = GetCurrentYearAccomplishmentsUseCase(repository: repository)

        let result = try sut.execute()

        #expect(result.isEmpty)
    }

    @Test("Returns all items when all belong to current year")
    func returnsAllWhenAllCurrentYear() throws {
        let currentYear = Calendar.current.component(.year, from: Date())
        let items = [makeItem(year: currentYear), makeItem(year: currentYear)]
        let repository = MockAccomplishmentRepository(items: items)
        let sut = GetCurrentYearAccomplishmentsUseCase(repository: repository)

        let result = try sut.execute()

        #expect(result.count == 2)
    }
}

private final class MockAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let items: [AccomplishmentItem]

    init(items: [AccomplishmentItem]) {
        self.items = items
    }

    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] { items }
    func save(_ accomplishment: NewAccomplishment) throws {}
    func delete(_ accomplishment: AccomplishmentItem) throws {}
}
