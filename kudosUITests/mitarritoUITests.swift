import XCTest
@testable import kudos

final class KudosUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddNewAccomplishment() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 1))
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 1))

        textEditor.typeText("My amazing accomplishment 🚀!")

        stickie.swipeUp()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 1))
        continueButton.tap()

        let tarritoButton = app.links["Jar Button"]
        XCTAssert(tarritoButton.waitForExistence(timeout: 1))
        tarritoButton.tap()

        let accomplishmentText = app.staticTexts["My amazing accomplishment 🚀!"]
        XCTAssert(accomplishmentText.waitForExistence(timeout: 1))
    }

    func testNavigateToAboutView() {
        let aboutButton = app.buttons["About me Button"]
        XCTAssert(aboutButton.waitForExistence(timeout: 2))
        aboutButton.tap()

        let aboutTitle = app.staticTexts["About me Title"]
        XCTAssertTrue(aboutTitle.waitForExistence(timeout: 2))
    }
}
