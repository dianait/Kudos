import Testing
import Foundation
@testable import kudos

@Suite("MainViewModel Tests")
@MainActor
struct MainViewModelTests {

    private func makeSUT(
        saveUseCase: MockSaveAccomplishmentUseCase = .init(),
        repository: MockAccomplishmentRepository = .init()
    ) -> MainViewModel {
        MainViewModel(
            saveAccomplishmentUseCase: saveUseCase,
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

    @Test("save with text calls use case with no photo")
    func saveWithTextCallsUseCaseWithNoPhoto() {
        let useCase = MockSaveAccomplishmentUseCase()
        let sut = makeSUT(saveUseCase: useCase)
        sut.text = "Mi logro"

        sut.save()

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.lastPhotoData == nil)
        #expect(useCase.lastText == "Mi logro")
    }

    @Test("save with photo calls use case with photo data")
    func saveWithPhotoCallsUseCaseWithPhotoData() {
        let useCase = MockSaveAccomplishmentUseCase()
        let photoData = Data([0x89, 0x50])
        let sut = makeSUT(saveUseCase: useCase)
        sut.selectedPhotoData = photoData

        sut.save()

        #expect(useCase.executeCallCount == 1)
        #expect(useCase.lastPhotoData == photoData)
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
        let sut = makeSUT(saveUseCase: .init(shouldThrow: true))
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

@MainActor
private final class MockSaveAccomplishmentUseCase: SaveAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    var lastText: String?
    var lastPhotoData: Data?
    private let shouldThrow: Bool

    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }

    func execute(text: String, photoData: Data?) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
        lastText = text
        lastPhotoData = photoData
    }
}

@MainActor
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
