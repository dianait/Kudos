import Testing
import Foundation
@testable import kudos

@Suite("WrappedViewModel Tests")
@MainActor
struct WrappedViewModelTests {

    @Test("load sets currentYearItems from use case")
    func loadSetsItems() {
        let items = [makeItem(), makeItem()]
        let sut = WrappedViewModel(getCurrentYearAccomplishmentsUseCase: MockUseCase(items: items))

        sut.load()

        #expect(sut.currentYearItems.count == 2)
    }

    @Test("load sets errorMessage on failure")
    func loadSetsErrorOnFailure() {
        let sut = WrappedViewModel(getCurrentYearAccomplishmentsUseCase: MockUseCase(shouldThrow: true))

        sut.load()

        #expect(sut.errorMessage != nil)
    }

    @Test("load clears previous errorMessage on success")
    func loadClearsPreviousError() {
        let sut = WrappedViewModel(getCurrentYearAccomplishmentsUseCase: MockUseCase())
        sut.errorMessage = "error previo"

        sut.load()

        #expect(sut.errorMessage == nil)
    }

    @Test("currentYear returns current calendar year")
    func currentYearMatchesCalendar() {
        let sut = WrappedViewModel(getCurrentYearAccomplishmentsUseCase: MockUseCase())
        let expected = Calendar.current.component(.year, from: Date())

        #expect(sut.currentYear == expected)
    }
}

private func makeItem() -> AccomplishmentItem {
    AccomplishmentItem(id: UUID().uuidString, date: Date(), text: "Logro", colorHex: "blue", photoData: nil)
}

private final class MockUseCase: GetCurrentYearAccomplishmentsUseCaseProtocol {
    private let items: [AccomplishmentItem]
    private let shouldThrow: Bool
    init(items: [AccomplishmentItem] = [], shouldThrow: Bool = false) {
        self.items = items
        self.shouldThrow = shouldThrow
    }
    func execute() throws -> [AccomplishmentItem] {
        if shouldThrow { throw TestError.generic }
        return items
    }
}

private enum TestError: Error { case generic }
