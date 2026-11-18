import Testing
import Foundation
@testable import kudos

@Suite("EditAccomplishmentUseCase Tests")
@MainActor
struct EditAccomplishmentUseCaseTests {

    @Test("updates trimmed text of a text kudo")
    func updatesTrimmedText() throws {
        let repository = BackupSpyRepository(items: [])
        let sut = EditAccomplishmentUseCase(repository: repository)

        try sut.execute(item: makeItem(id: "a"), newText: "  Nuevo texto \n")

        #expect(repository.lastTextUpdate?.id == "a")
        #expect(repository.lastTextUpdate?.text == "Nuevo texto")
    }

    @Test("rejects empty text on a text-only kudo")
    func rejectsEmptyTextWithoutPhoto() {
        let repository = BackupSpyRepository(items: [])
        let sut = EditAccomplishmentUseCase(repository: repository)

        #expect(throws: ValidationError.emptyText) {
            try sut.execute(item: makeItem(id: "a"), newText: "   ")
        }
        #expect(repository.lastTextUpdate == nil)
    }

    @Test("allows clearing the caption of a photo kudo")
    func allowsEmptyCaptionWithPhoto() throws {
        let repository = BackupSpyRepository(items: [])
        let sut = EditAccomplishmentUseCase(repository: repository)

        try sut.execute(item: makeItem(id: "p", photo: Data([0x01])), newText: "  ")

        #expect(repository.lastTextUpdate?.text == "")
    }

    @Test("rejects text over the limit", arguments: [false, true])
    func rejectsTooLongText(hasPhoto: Bool) {
        let repository = BackupSpyRepository(items: [])
        let sut = EditAccomplishmentUseCase(repository: repository)
        let tooLong = String(repeating: "a", count: AccomplishmentValidator.maxTextLength + 1)

        #expect(throws: ValidationError.textTooLong(maxLength: AccomplishmentValidator.maxTextLength)) {
            try sut.execute(item: makeItem(id: "a", photo: hasPhoto ? Data([0x01]) : nil), newText: tooLong)
        }
        #expect(repository.lastTextUpdate == nil)
    }

    private func makeItem(id: String, photo: Data? = nil) -> AccomplishmentItem {
        AccomplishmentItem(id: id, date: Date(), text: "Antes", colorHex: "blue", photoData: photo)
    }
}
