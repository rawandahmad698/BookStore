//
//  BookStoreUITests.swift
//  BookStoreUITests
//
//  Created by Rawand Ahmad on 02/10/2023.
//

import XCTest

final class BookStoreUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app.launch()
    }
    func testSearchField() throws {
        
        let searchField = app.searchFields["Type something here to search"]
        
        searchField.tap()
        searchField.typeText("Swift")
        app.buttons["Search"].tap()
        
        let tableView = app.tables["ResultsTable"]
        
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "Table view did not appear")
        
        let cells = tableView.cells
        
        // Wait for the cells to appear
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 10))

        let cellCount = tableView.cells.count
        XCTAssertEqual(cellCount, 50)
    }
}
