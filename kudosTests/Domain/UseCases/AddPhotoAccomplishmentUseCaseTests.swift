import Testing
import Foundation
@testable import kudos

@Suite("AddPhotoAccomplishmentUseCase Tests")
struct AddPhotoAccomplishmentUseCaseTests {

    private let samplePhoto = Data([0x89, 0x50, 0x4E, 0x47])

    @Test("Saves photo data and color with nil text when no caption provided")
    func savesPhotoWithNilCaption() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddPhotoAccomplishmentUseCase(repository: repository)

        try sut.execute(photoData: samplePhoto, caption: nil, color: "blue")

        let saved = try #require(repository.savedAccomplishment)
        #expect(saved.photoData == samplePhoto)
        #expect(saved.text == nil)
        #expect(saved.color == "blue")
    }

    @Test("Saves photo with trimmed caption as text")
    func savesPhotoWithTrimmedCaption() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddPhotoAccomplishmentUseCase(repository: repository)

        try sut.execute(photoData: samplePhoto, caption: "  Mi foto  ", color: "yellow")

        #expect(repository.savedAccomplishment?.text == "Mi foto")
    }

    @Test("Treats whitespace-only caption as nil text")
    func treatsWhitespaceCaptionAsNil() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddPhotoAccomplishmentUseCase(repository: repository)

        try sut.execute(photoData: samplePhoto, caption: "   ", color: "blue")

        #expect(repository.savedAccomplishment?.text == nil)
    }

    @Test("Treats empty caption as nil text")
    func treatsEmptyCaptionAsNil() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddPhotoAccomplishmentUseCase(repository: repository)

        try sut.execute(photoData: samplePhoto, caption: "", color: "blue")

        #expect(repository.savedAccomplishment?.text == nil)
    }

    @Test("Throws textTooLong when caption exceeds max characters")
    func throwsTextTooLongWhenCaptionExceedsMax() {
        let sut = AddPhotoAccomplishmentUseCase(repository: SpyAccomplishmentRepository())
        let longCaption = String(repeating: "a", count: Limits.maxCharacters + 1)

        #expect(throws: ValidationError.textTooLong(maxLength: Limits.maxCharacters)) {
            try sut.execute(photoData: samplePhoto, caption: longCaption, color: "blue")
        }
    }

    @Test("Does not save when caption validation fails")
    func doesNotSaveWhenValidationFails() {
        let repository = SpyAccomplishmentRepository()
        let sut = AddPhotoAccomplishmentUseCase(repository: repository)
        let longCaption = String(repeating: "a", count: Limits.maxCharacters + 1)

        try? sut.execute(photoData: samplePhoto, caption: longCaption, color: "blue")

        #expect(repository.savedAccomplishment == nil)
    }
}

private final class SpyAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    var savedAccomplishment: NewAccomplishment?

    func save(_ accomplishment: NewAccomplishment) throws {
        savedAccomplishment = accomplishment
    }

    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] { [] }
    func delete(_ accomplishment: AccomplishmentItem) throws {}
}
