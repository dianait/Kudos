import Testing
import Foundation
@testable import kudos

@Suite("MainViewModel Tests")
@MainActor
struct MainViewModelTests {

    private func makeSUT(
        addAccomplishment: MockAddAccomplishmentUseCase = .init(),
        addPhotoAccomplishment: MockAddPhotoAccomplishmentUseCase = .init(),
        repository: MockAccomplishmentRepository = .init()
    ) -> MainViewModel {
        MainViewModel(
            addAccomplishmentUseCase: addAccomplishment,
            addPhotoAccomplishmentUseCase: addPhotoAccomplishment,
            repository: repository
        )
    }

    // MARK: - loadAccomplishments

    @Test("loadAccomplishments sets accomplishments from repository")
    func loadSetsAccomplishments() {
        let items = [makeItem(), makeItem()]
        let sut = makeSUT(repository: .init(items: items))

        sut.loadAccomplishments()

        #expect(sut.accomplishments.count == 2)
    }

    @Test("loadAccomplishments sets errorMessage on failure")
    func loadSetsErrorOnFailure() {
        let sut = makeSUT(repository: .init(fetchThrows: true))

        sut.loadAccomplishments()

        #expect(sut.errorMessage != nil)
    }

    // MARK: - save

    @Test("save with text calls text use case")
    func saveWithTextCallsTextUseCase() {
        let textUseCase = MockAddAccomplishmentUseCase()
        let sut = makeSUT(addAccomplishment: textUseCase)
        sut.text = "Mi logro"

        sut.save()

        #expect(textUseCase.executeCallCount == 1)
    }

    @Test("save with photo calls photo use case")
    func saveWithPhotoCallsPhotoUseCase() {
        let photoUseCase = MockAddPhotoAccomplishmentUseCase()
        let sut = makeSUT(addPhotoAccomplishment: photoUseCase)
        sut.selectedPhotoData = Data([0x89, 0x50])

        sut.save()

        #expect(photoUseCase.executeCallCount == 1)
    }

    @Test("save resets state and shows saved message on success")
    func saveResetsStateOnSuccess() {
        let sut = makeSUT()
        sut.text = "Mi logro"
        sut.selectedPhotoData = nil

        sut.save()

        #expect(sut.text == "")
        #expect(sut.mode == .view)
        #expect(sut.showSavedMessage == true)
        #expect(sut.errorMessage == nil)
        #expect(sut.selectedPhotoData == nil)
    }

    @Test("save sets errorMessage on failure")
    func saveSetsErrorOnFailure() {
        let sut = makeSUT(addAccomplishment: .init(shouldThrow: true))
        sut.text = "Mi logro"

        sut.save()

        #expect(sut.errorMessage != nil)
        #expect(sut.showSavedMessage == false)
    }

    @Test("save reloads accomplishments on success")
    func saveReloadsAccomplishments() {
        let items = [makeItem()]
        let sut = makeSUT(repository: .init(items: items))
        sut.text = "Mi logro"

        sut.save()

        #expect(sut.accomplishments.count == 1)
    }

    // MARK: - delete

    @Test("delete calls repository and reloads accomplishments")
    func deleteDelegatesAndReloads() {
        let repository = MockAccomplishmentRepository(items: [makeItem()])
        let sut = makeSUT(repository: repository)

        sut.delete(makeItem())

        #expect(repository.deleteCallCount == 1)
        #expect(sut.accomplishments.count == 1)
    }

    @Test("delete sets errorMessage on failure")
    func deleteSetsErrorOnFailure() {
        let sut = makeSUT(repository: .init(deleteThrows: true))

        sut.delete(makeItem())

        #expect(sut.errorMessage != nil)
    }

    // MARK: - hideSavedMessage

    @Test("hideSavedMessage sets showSavedMessage to false")
    func hideSavedMessageClearsFlag() {
        let sut = makeSUT()
        sut.showSavedMessage = true

        sut.hideSavedMessage()

        #expect(sut.showSavedMessage == false)
    }

    // MARK: - accomplishmentsCount

    @Test("accomplishmentsCount reflects accomplishments array")
    func accomplishmentsCountMatchesArray() {
        let sut = makeSUT(repository: .init(items: [makeItem(), makeItem(), makeItem()]))
        sut.loadAccomplishments()

        #expect(sut.accomplishmentsCount == 3)
    }
}

private func makeItem() -> AccomplishmentItem {
    AccomplishmentItem(id: UUID().uuidString, date: Date(), text: "Logro", colorHex: "blue", photoData: nil)
}

private final class MockAddAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    private let shouldThrow: Bool
    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }
    func execute(text: String) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
    }
}

private final class MockAddPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    private let shouldThrow: Bool
    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }
    func execute(photoData: Data, caption: String?) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
    }
}

private final class MockAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let items: [AccomplishmentItem]
    private let fetchThrows: Bool
    private let deleteThrows: Bool
    var deleteCallCount = 0

    init(items: [AccomplishmentItem] = [], fetchThrows: Bool = false, deleteThrows: Bool = false) {
        self.items = items
        self.fetchThrows = fetchThrows
        self.deleteThrows = deleteThrows
    }

    func save(_ accomplishment: NewAccomplishment) throws {}

    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] {
        if fetchThrows { throw TestError.generic }
        return items
    }

    func delete(_ accomplishment: AccomplishmentItem) throws {
        if deleteThrows { throw TestError.generic }
        deleteCallCount += 1
    }
}

private enum TestError: Error { case generic }
