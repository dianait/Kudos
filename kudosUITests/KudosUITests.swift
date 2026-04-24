import XCTest

final class KudosUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    // MARK: - Save via swipe

    func testAddNewAccomplishment() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 2))
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 2))
        textEditor.typeText("My amazing accomplishment 🚀!")

        stickie.swipeUp()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()

        let jarButton = app.links["Jar Button"]
        XCTAssert(jarButton.waitForExistence(timeout: 2))
        jarButton.tap()

        let accomplishmentText = app.staticTexts["My amazing accomplishment 🚀!"]
        XCTAssert(accomplishmentText.waitForExistence(timeout: 2))
    }

    // MARK: - Save via button

    func testSaveAccomplishmentViaSaveButton() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 2))
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 2))
        textEditor.typeText("Completed my first PR review")

        let saveButton = app.buttons["Save Button"]
        XCTAssert(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()

        XCTAssertFalse(app.textViews["Text Editor"].exists)
        XCTAssert(app.links["Jar Button"].waitForExistence(timeout: 2))
    }

    // MARK: - Cancel editing

    func testCancelEditingResetsState() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 2))
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 2))
        textEditor.typeText("This will be cancelled")

        let cancelButton = app.buttons["Cancel button"]
        XCTAssert(cancelButton.waitForExistence(timeout: 2))
        cancelButton.tap()

        XCTAssertFalse(app.textViews["Text Editor"].exists)
        XCTAssert(app.buttons["Main Stickie"].waitForExistence(timeout: 2))
    }

    // MARK: - Delete accomplishment

    func testDeleteAccomplishment() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 2))
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 2))
        textEditor.typeText("To be deleted")

        let saveButton = app.buttons["Save Button"]
        XCTAssert(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 2))
        continueButton.tap()

        let jarButton = app.links["Jar Button"]
        XCTAssert(jarButton.waitForExistence(timeout: 2))
        jarButton.tap()

        let carouselItem = app.buttons["Achievement 1 Button"]
        XCTAssert(carouselItem.waitForExistence(timeout: 2))
        carouselItem.tap()

        let deleteButton = app.buttons["Delete achievement"]
        XCTAssert(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        let confirmButton = app.alerts.firstMatch.buttons["Delete Alert Button"].firstMatch
        XCTAssert(confirmButton.waitForExistence(timeout: 2))
        confirmButton.tap()

        let emptyTitle = app.buttons["Add Achievement Carousel Empty State Button"]
        XCTAssert(emptyTitle.waitForExistence(timeout: 2))
    }
}
