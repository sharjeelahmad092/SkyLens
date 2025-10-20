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

        // Give plenty of time for app to launch and splash screen to disappear
        sleep(5)

        // Just verify that we can see the tab bar (simpler check)
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))

        // Make sure there are at least 2 tabs (Weather and Contact)
        XCTAssertGreaterThanOrEqual(app.tabBars.buttons.count, 2, "App should have at least 2 tab bar buttons")

        // Check that we can see a refresh button somewhere (part of weather screen)
        // If we can, we're on a weather-related screen
        XCTAssertTrue(app.buttons["Refresh"].waitForExistence(timeout: 5), "Should show weather screen with refresh button")
    }

    @MainActor
    func testContactFormValidation() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to disappear completely
        sleep(5)

        // Navigate to Contact tab with verification
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5), "Tab bar not found")
        let contactTab = app.tabBars.buttons["Contact"]
        XCTAssertTrue(contactTab.exists, "Contact tab not found")
        contactTab.tap()

        // Verify the header exists
        let getInTouch = app.staticTexts["Get in Touch"]
        XCTAssertTrue(getInTouch.waitForExistence(timeout: 5), "Contact screen header not found")

        // Find submit button with increased timeout
        let submitButton = app.buttons["Submit"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "Submit button not found")

        // Tap submit button
        submitButton.tap()

        // Wait for validation errors with increased timeout
        // Check for name error message
        let nameError = app.staticTexts["Name cannot be empty"]
        XCTAssertTrue(nameError.waitForExistence(timeout: 5), "Name validation error not shown")

        // Check for email error
        let emailError = app.staticTexts["Email cannot be empty"]
        XCTAssertTrue(emailError.waitForExistence(timeout: 5), "Email validation error not shown")
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
