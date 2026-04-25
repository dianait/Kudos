import Testing
import Foundation
@testable import kudos

@Suite("SaveAccomplishmentUseCase Tests")
@MainActor
struct SaveAccomplishmentUseCaseTests {

    private func makeSUT(
        addAccomplishment: MockAddAccomplishmentUseCase = .init(),
        addPhotoAccomplishment: MockAddPhotoAccomplishmentUseCase = .init()
    ) -> SaveAccomplishmentUseCase {
        SaveAccomplishmentUseCase(
            addAccomplishmentUseCase: addAccomplishment,
            addPhotoAccomplishmentUseCase: addPhotoAccomplishment
        )
    }

    // MARK: - Routing

    @Test("execute with no photo delegates to AddAccomplishmentUseCase")
    func noPhotoDelegatesToTextUseCase() throws {
        let textUseCase = MockAddAccomplishmentUseCase()
        let photoUseCase = MockAddPhotoAccomplishmentUseCase()
        let sut = makeSUT(addAccomplishment: textUseCase, addPhotoAccomplishment: photoUseCase)

        try sut.execute(text: "Mi logro", photoData: nil)

        #expect(textUseCase.executeCallCount == 1)
        #expect(textUseCase.lastText == "Mi logro")
        #expect(photoUseCase.executeCallCount == 0)
    }

    @Test("execute with photo delegates to AddPhotoAccomplishmentUseCase")
    func withPhotoDelegatesToPhotoUseCase() throws {
        let textUseCase = MockAddAccomplishmentUseCase()
        let photoUseCase = MockAddPhotoAccomplishmentUseCase()
        let photoData = Data([0x89, 0x50])
        let sut = makeSUT(addAccomplishment: textUseCase, addPhotoAccomplishment: photoUseCase)

        try sut.execute(text: "Caption", photoData: photoData)

        #expect(photoUseCase.executeCallCount == 1)
        #expect(photoUseCase.lastPhotoData == photoData)
        #expect(photoUseCase.lastCaption == "Caption")
        #expect(textUseCase.executeCallCount == 0)
    }

    @Test("execute with photo passes caption as-is to photo use case")
    func withPhotoPassesCaptionToPhotoUseCase() throws {
        let photoUseCase = MockAddPhotoAccomplishmentUseCase()
        let photoData = Data([0x01])
        let sut = makeSUT(addPhotoAccomplishment: photoUseCase)

        try sut.execute(text: "  texto  ", photoData: photoData)

        #expect(photoUseCase.lastCaption == "  texto  ")
    }

    // MARK: - Error propagation

    @Test("execute propagates error from text use case")
    func propagatesTextUseCaseError() {
        let sut = makeSUT(addAccomplishment: .init(shouldThrow: true))

        #expect(throws: (any Error).self) {
            try sut.execute(text: "Mi logro", photoData: nil)
        }
    }

    @Test("execute propagates error from photo use case")
    func propagatesPhotoUseCaseError() {
        let sut = makeSUT(addPhotoAccomplishment: .init(shouldThrow: true))

        #expect(throws: (any Error).self) {
            try sut.execute(text: "Caption", photoData: Data([0x01]))
        }
    }
}

@MainActor
private final class MockAddAccomplishmentUseCase: AddAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    var lastText: String?
    private let shouldThrow: Bool

    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }

    func execute(text: String) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
        lastText = text
    }
}

@MainActor
private final class MockAddPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCaseProtocol {
    var executeCallCount = 0
    var lastPhotoData: Data?
    var lastCaption: String?
    private let shouldThrow: Bool

    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }

    func execute(photoData: Data, caption: String?) throws {
        if shouldThrow { throw TestError.generic }
        executeCallCount += 1
        lastPhotoData = photoData
        lastCaption = caption
    }
}

private enum TestError: Error { case generic }
