import XCTest

final class DisneyCharactersUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Splash

    func testSplash_logoAndStartButtonAreVisible() {
        XCTAssertTrue(app.images["splash_logo"].exists)
        XCTAssertTrue(app.buttons["splash_start_button"].exists)
    }

    func testSplash_tapStart_showsCharacterList() {
        app.buttons["splash_start_button"].tap()
        XCTAssertTrue(
            app.otherElements["character_list_search_bar"].waitForExistence(timeout: 5)
        )
    }

    // MARK: - Character List

    func testCharacterList_loadsRowsFromAPI() {
        app.buttons["splash_start_button"].tap()
        let firstRow = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'character_list_row_'")
        ).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 30))
    }

    // MARK: - Navigation: List → Detail

    func testCharacterList_tapRow_showsCharacterDetail() {
        app.buttons["splash_start_button"].tap()
        let firstRow = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'character_list_row_'")
        ).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 30))
        firstRow.tap()
        XCTAssertTrue(
            app.images["character_detail_image"].waitForExistence(timeout: 30)
        )
    }

    func testCharacterDetail_backButton_returnsToCharacterList() {
        app.buttons["splash_start_button"].tap()
        let firstRow = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'character_list_row_'")
        ).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 30))
        firstRow.tap()
        XCTAssertTrue(
            app.images["character_detail_image"].waitForExistence(timeout: 30)
        )
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(
            app.otherElements["character_list_search_bar"].waitForExistence(timeout: 5)
        )
    }
}
