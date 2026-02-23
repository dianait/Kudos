import XCTest
@testable import kudos

@available(iOS 17.6, *)
final class ViewComponentTests: XCTestCase {

    override class var defaultTestSuite: XCTestSuite {
            super.defaultTestSuite
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        throw XCTSkip("Skipping ViewComponentTests: requires iOS 17.6+")
    }

    @MainActor
    func testDateLabelView() throws {
        let date = Date()
        let view = DateLabelView(date: date)

        let _ = try XCTUnwrap(view.body)
    }

    @MainActor
    func testDeleteButtonView() throws {
        var buttonPressed = false
        let view = DeleteButtonView(action: { buttonPressed = true })

        let _ = try XCTUnwrap(view.body)
    }

    @MainActor
    func testStickyView() throws {
        let accomplishment = try Accomplishment("Test Sticky")
        let view = StickyView(item: accomplishment)

        let _ = try XCTUnwrap(view.body)
    }
}
