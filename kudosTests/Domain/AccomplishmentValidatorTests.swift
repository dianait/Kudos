import Testing
import Foundation
@testable import kudos

@Suite("AccomplishmentValidator Tests")
struct AccomplishmentValidatorTests {

    @Test("Returns trimmed text for valid input")
    func returnsTrimmendTextForValidInput() throws {
        let result = try AccomplishmentValidator.validateText("  Terminé el proyecto  ")
        #expect(result == "Terminé el proyecto")
    }

    @Test("Returns text unchanged when no whitespace to trim")
    func returnsUnchangedTextWithNoWhitespace() throws {
        let result = try AccomplishmentValidator.validateText("Mi logro")
        #expect(result == "Mi logro")
    }

    @Test("Throws emptyText for empty string")
    func throwsEmptyTextForEmptyString() {
        #expect(throws: ValidationError.emptyText) {
            try AccomplishmentValidator.validateText("")
        }
    }

    @Test("Throws emptyText for whitespace-only string")
    func throwsEmptyTextForWhitespaceOnly() {
        #expect(throws: ValidationError.emptyText) {
            try AccomplishmentValidator.validateText("   ")
        }
    }

    @Test("Throws emptyText for newline-only string")
    func throwsEmptyTextForNewlineOnly() {
        #expect(throws: ValidationError.emptyText) {
            try AccomplishmentValidator.validateText("\n\n")
        }
    }

    @Test("Accepts text exactly at max length")
    func acceptsTextAtMaxLength() throws {
        let text = String(repeating: "a", count: Limits.maxCharacters)
        let result = try AccomplishmentValidator.validateText(text)
        #expect(result.count == Limits.maxCharacters)
    }

    @Test("Throws textTooLong when text exceeds max length")
    func throwsTextTooLongWhenExceedsMax() {
        let text = String(repeating: "a", count: Limits.maxCharacters + 1)
        #expect(throws: ValidationError.textTooLong(maxLength: Limits.maxCharacters)) {
            try AccomplishmentValidator.validateText(text)
        }
    }

    @Test("Throws textTooLong based on trimmed length")
    func throwsTextTooLongBasedOnTrimmedLength() throws {
        let text = String(repeating: "a", count: Limits.maxCharacters)
        let result = try AccomplishmentValidator.validateText("  \(text)  ")
        #expect(result.count == Limits.maxCharacters)
    }
}
