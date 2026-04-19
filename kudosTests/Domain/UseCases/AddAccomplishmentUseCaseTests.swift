import Testing
import Foundation
@testable import kudos

@Suite("AddAccomplishmentUseCase Tests")
struct AddAccomplishmentUseCaseTests {

    @Test("Saves accomplishment with validated text and given color")
    func savesWithValidTextAndColor() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddAccomplishmentUseCase(repository: repository)

        try sut.execute(text: "Terminé el proyecto", color: "blue")

        let saved = try #require(repository.savedAccomplishment)
        #expect(saved.text == "Terminé el proyecto")
        #expect(saved.color == "blue")
        #expect(saved.photoData == nil)
    }

    @Test("Trims whitespace from text before saving")
    func trimsWhitespaceBeforeSaving() throws {
        let repository = SpyAccomplishmentRepository()
        let sut = AddAccomplishmentUseCase(repository: repository)

        try sut.execute(text: "  Mi logro  ", color: "yellow")

        #expect(repository.savedAccomplishment?.text == "Mi logro")
    }

    @Test("Throws emptyText for empty string")
    func throwsEmptyTextForEmptyString() {
        let sut = AddAccomplishmentUseCase(repository: SpyAccomplishmentRepository())

        #expect(throws: ValidationError.emptyText) {
            try sut.execute(text: "", color: "blue")
        }
    }

    @Test("Throws emptyText for whitespace-only string")
    func throwsEmptyTextForWhitespace() {
        let sut = AddAccomplishmentUseCase(repository: SpyAccomplishmentRepository())

        #expect(throws: ValidationError.emptyText) {
            try sut.execute(text: "   ", color: "blue")
        }
    }

    @Test("Throws textTooLong when text exceeds max characters")
    func throwsTextTooLongWhenTextExceedsMax() {
        let sut = AddAccomplishmentUseCase(repository: SpyAccomplishmentRepository())
        let longText = String(repeating: "a", count: Limits.maxCharacters + 1)

        #expect(throws: ValidationError.textTooLong(maxLength: Limits.maxCharacters)) {
            try sut.execute(text: longText, color: "blue")
        }
    }

    @Test("Does not save when validation fails")
    func doesNotSaveWhenValidationFails() {
        let repository = SpyAccomplishmentRepository()
        let sut = AddAccomplishmentUseCase(repository: repository)

        try? sut.execute(text: "", color: "blue")

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
