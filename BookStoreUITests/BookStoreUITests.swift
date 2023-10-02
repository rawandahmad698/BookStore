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
    func testExample() throws {
        
        let searchField = app.searchFields["Type something here to search"]
        
        searchField.tap()
        searchField.typeText("Swift")
        app.buttons["Search"].tap()
        
        let tableView = app.tables["ResultsTable"]
        
        XCTAssertTrue(tableView.waitForExistence(timeout: 10), "Table view did not appear")
        
        let cell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "Table cell not found")
    }
}
