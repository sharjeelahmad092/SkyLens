//
//  SkyLensUITests.swift
//  SkyLensUITests
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import XCTest

final class SkyLensUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testWeatherTabNavigationAndBasicFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify we're on the Weather tab
        let weatherTab = app.tabBars.buttons["Weather"]
        XCTAssertTrue(weatherTab.exists)

        // Wait for content to load (give network time)
        let exists = NSPredicate(format: "exists == true")
        let refreshButton = app.buttons["Refresh"]
        expectation(for: exists, evaluatedWith: refreshButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        // Navigate to Contact tab
        app.tabBars.buttons["Contact"].tap()

        // Verify Contact form elements
        XCTAssertTrue(app.navigationBars["Contact Us"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.textFields["Phone"].exists)
        XCTAssertTrue(app.buttons["Submit"].exists)

        // Go back to weather tab
        weatherTab.tap()
        XCTAssertTrue(app.navigationBars["Weather"].exists)
    }

    @MainActor
    func testContactFormValidation() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Contact tab
        app.tabBars.buttons["Contact"].tap()

        // Try to submit empty form
        let submitButton = app.buttons["Submit"]
        submitButton.tap()

        // Should show validation errors
        let nameError = app.staticTexts["Name cannot be empty"]
        XCTAssertTrue(nameError.waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
