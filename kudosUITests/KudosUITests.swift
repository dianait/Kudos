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
        XCTAssert(stickie.waitForExistence(timeout: 5), "stickie not found")
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 5), "textEditor not found")
        textEditor.typeText("My amazing accomplishment 🚀!")

        stickie.swipeUp()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 5), "continueButton not found")
        continueButton.tap()

        let jarButton = app.buttons["Jar Button"]
        XCTAssert(jarButton.waitForExistence(timeout: 5), "jarButton not found")
        jarButton.tap()

        let accomplishmentText = app.staticTexts["My amazing accomplishment 🚀!"]
        XCTAssert(accomplishmentText.waitForExistence(timeout: 5), "accomplishmentText not found")
    }

    // MARK: - Save via button

    func testSaveAccomplishmentViaSaveButton() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 5), "stickie not found")
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 5), "textEditor not found")
        textEditor.typeText("Completed my first PR review")

        let saveButton = app.buttons["Save Button"]
        XCTAssert(saveButton.waitForExistence(timeout: 5), "saveButton not found")
        saveButton.tap()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 5), "continueButton not found")
        continueButton.tap()

        XCTAssertFalse(app.textViews["Text Editor"].exists, "Text Editor still visible")
        XCTAssert(app.buttons["Jar Button"].waitForExistence(timeout: 5), "Jar Button not found")
    }

    // MARK: - Cancel editing

    func testCancelEditingResetsState() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 5), "stickie not found")
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 5), "textEditor not found")
        textEditor.typeText("This will be cancelled")

        let cancelButton = app.buttons["Cancel button"]
        XCTAssert(cancelButton.waitForExistence(timeout: 5), "cancelButton not found")
        cancelButton.tap()

        XCTAssertFalse(app.textViews["Text Editor"].exists, "Text Editor still visible")
        XCTAssert(app.buttons["Main Stickie"].waitForExistence(timeout: 5), "Main Stickie not found")
    }

    // MARK: - Delete accomplishment

    func testDeleteAccomplishment() {
        let stickie = app.buttons["Main Stickie"]
        XCTAssert(stickie.waitForExistence(timeout: 5), "stickie not found")
        stickie.tap()

        let textEditor = app.textViews["Text Editor"]
        XCTAssert(textEditor.waitForExistence(timeout: 5), "textEditor not found")
        textEditor.typeText("To be deleted")

        let saveButton = app.buttons["Save Button"]
        XCTAssert(saveButton.waitForExistence(timeout: 5), "saveButton not found")
        saveButton.tap()

        let continueButton = app.buttons["Continue Button"]
        XCTAssert(continueButton.waitForExistence(timeout: 5), "continueButton not found")
        continueButton.tap()

        let jarButton = app.buttons["Jar Button"]
        XCTAssert(jarButton.waitForExistence(timeout: 5), "jarButton not found")
        jarButton.tap()

        let carouselItem = app.buttons["Achievement 1 Button"]
        XCTAssert(carouselItem.waitForExistence(timeout: 5), "carouselItem not found")
        carouselItem.tap()

        let deleteButton = app.buttons["Delete achievement"]
        XCTAssert(deleteButton.waitForExistence(timeout: 5), "deleteButton not found")
        deleteButton.tap()

        let confirmButton = app.alerts.firstMatch.buttons["Delete Alert Button"].firstMatch
        XCTAssert(confirmButton.waitForExistence(timeout: 5), "confirmButton not found")
        confirmButton.tap()

        let emptyTitle = app.buttons["Add Achievement Carousel Empty State Button"]
        XCTAssert(emptyTitle.waitForExistence(timeout: 5), "emptyTitle not found")
    }
}
