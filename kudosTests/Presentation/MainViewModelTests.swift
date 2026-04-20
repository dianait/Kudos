import Testing
import Foundation
@testable import kudos

@Suite("MainViewModel Tests")
@MainActor
struct MainViewModelTests {

    private func makeSUT(
        addAccomplishment: MockAddAccomplishmentUseCase = .init(),
        addPhotoAccomplishment: MockAddPhotoAccomplishmentUseCase = .init(),
        getAccomplishments: MockGetAccomplishmentsUseCase = .init(),
        deleteAccomplishment: MockDeleteAccomplishmentUseCase = .init()
    ) -> MainViewModel {
        MainViewModel(
            addAccomplishmentUseCase: addAccomplishment,
            addPhotoAccomplishmentUseCase: addPhotoAccomplishment,
            getAccomplishmentsUseCase: getAccomplishments,
            deleteAccomplishmentUseCase: deleteAccomplishment
        )
    }

    // MARK: - loadAccomplishments

    @Test("loadAccomplishments sets accomplishments from use case")
    func loadSetsAccomplishments() {
        let items = [makeItem(), makeItem()]
        let sut = makeSUT(getAccomplishments: .init(items: items))

        sut.loadAccomplishments()

        #expect(sut.accomplishments.count == 2)
    }

    @Test("loadAccomplishments sets errorMessage on failure")
    func loadSetsErrorOnFailure() {
        let sut = makeSUT(getAccomplishments: .init(shouldThrow: true))

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
        let getUseCase = MockGetAccomplishmentsUseCase(items: items)
        let sut = makeSUT(getAccomplishments: getUseCase)
        sut.text = "Mi logro"

        sut.save()

        #expect(sut.accomplishments.count == 1)
    }

    // MARK: - delete

    @Test("delete calls use case and reloads accomplishments")
    func deleteDelegatesAndReloads() {
        let deleteUseCase = MockDeleteAccomplishmentUseCase()
        let items = [makeItem()]
        let sut = makeSUT(
            getAccomplishments: .init(items: items),
            deleteAccomplishment: deleteUseCase
        )

        sut.delete(makeItem())

        #expect(deleteUseCase.executeCallCount == 1)
        #expect(sut.accomplishments.count == 1)
    }

    @Test("delete sets errorMessage on failure")
    func deleteSetsErrorOnFailure() {
        let sut = makeSUT(deleteAccomplishment: .init(shouldThrow: true))

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
        let sut = makeSUT(getAccomplishments: .init(items: [makeItem(), makeItem(), makeItem()]))
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

private final class MockGetAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol {
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

private final class MockDeleteAccomplishmentUseCase: DeleteAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    private let shouldThrow: Bool
    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }
    func execute(_ accomplishment: AccomplishmentItem) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
    }
}

private enum TestError: Error { case generic }
