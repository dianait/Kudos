import Testing
import Foundation
@testable import kudos

@Suite("Accomplishment Tests")
struct AccomplishmentTests {

    @Test("Initializes with valid text and color")
    func initializationWithTextAndColor() throws {
        let text = "Mi primer logro"
        let color = "blue"

        let accomplishment = try Accomplishment(text, color: color)

        #expect(accomplishment.text == text)
        #expect(accomplishment.color == color)
        #expect(accomplishment.date <= Date())
    }

    @Test("Assigns random color from available palette when none specified")
    func randomColorInitialization() throws {
        let accomplishment = try Accomplishment("Test logro")

        #expect(accomplishment.text == "Test logro")
        #expect(AccomplishmentColor.availableColorStrings.contains(accomplishment.color))
    }

    @Test("Validation rejects invalid text", arguments: [
        ("", ValidationError.emptyText),
        (String(repeating: "a", count: Limits.maxCharacters + 1), ValidationError.textTooLong(maxLength: Limits.maxCharacters))
    ] as [(String, ValidationError)])
    func validationRejectsInvalidText(input: String, expectedError: ValidationError) {
        #expect(throws: expectedError) {
            try Accomplishment(input)
        }
    }

    @Test("Trims leading and trailing whitespace from text")
    func trimmingWhitespace() throws {
        let accomplishment = try Accomplishment("  Mi logro  ")

        #expect(accomplishment.text == "Mi logro")
    }
}
