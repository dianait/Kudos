import XCTest
@testable import kudos

final class AccomplishmentTests: XCTestCase {

    func testAccomplishmentInitialization() throws {
        let text = "Mi primer logro"
        let color = "blue"

        let accomplishment = try Accomplishment(text, color: color)

        XCTAssertEqual(accomplishment.text, text)
        XCTAssertEqual(accomplishment.color, color)
        XCTAssertNotNil(accomplishment.date)
    }

    func testRandomColorInitialization() throws {
        let text = "Test logro"
        let accomplishment = try Accomplishment(text)

        XCTAssertEqual(accomplishment.text, text)
        XCTAssertTrue(AccomplishmentColor.availableColorStrings.contains(accomplishment.color))
    }
    
    func testAccomplishmentValidationEmptyText() {
        XCTAssertThrowsError(try Accomplishment("")) { error in
            XCTAssertTrue(error is ValidationError)
            if let validationError = error as? ValidationError {
                XCTAssertEqual(validationError, .emptyText)
            }
        }
    }
    
    func testAccomplishmentValidationTextTooLong() {
        let longText = String(repeating: "a", count: Limits.maxCharacters + 1)
        XCTAssertThrowsError(try Accomplishment(longText)) { error in
            XCTAssertTrue(error is ValidationError)
            if let validationError = error as? ValidationError {
                if case .textTooLong = validationError {
                    // Expected error
                } else {
                    XCTFail("Expected textTooLong error")
                }
            }
        }
    }
    
    func testAccomplishmentTrimsWhitespace() throws {
        let textWithWhitespace = "  Mi logro  "
        let accomplishment = try Accomplishment(textWithWhitespace)
        
        XCTAssertEqual(accomplishment.text, "Mi logro")
    }
}
