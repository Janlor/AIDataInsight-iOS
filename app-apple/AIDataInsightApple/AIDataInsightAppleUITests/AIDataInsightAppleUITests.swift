//
//  AIDataInsightAppleUITests.swift
//  AIDataInsightAppleUITests
//
//  Created by Janlor on 5/19/26.
//

import Foundation
import XCTest

final class AIDataInsightAppleUITests: XCTestCase {

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
    func testLaunchShowsWorkspace() throws {
        let app = launchAndLogin()

        XCTAssertEqual(app.state, .runningForeground)
        XCTAssertTrue(app.descendants(matching: .any)["history-sidebar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["ai-chat-welcome-bubble"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["New Chat"].exists)
    }

    @MainActor
    func testWorkspaceHistoryNewChatAndSettings() throws {
        let app = launchAndLogin()

        let firstHistory = app.staticTexts["history-row-100"].firstMatch
        XCTAssertTrue(firstHistory.waitForExistence(timeout: 5))
        firstHistory.click()
        let historyAnswer = app.staticTexts
            .matching(NSPredicate(format: "value CONTAINS %@", "整体向好"))
            .firstMatch
        XCTAssertTrue(historyAnswer.waitForExistence(timeout: 5))

        let newChat = app.buttons["toolbar-new-chat-button"].firstMatch
        XCTAssertTrue(newChat.waitForExistence(timeout: 5))
        newChat.click()
        XCTAssertTrue(app.descendants(matching: .any)["ai-chat-welcome-bubble"].waitForExistence(timeout: 5))

        app.buttons["Settings"].firstMatch.click()
        XCTAssertTrue(app.descendants(matching: .any)["setting-screen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["setting-row-privacy"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["setting-row-logout"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLogoutReturnsToLogin() throws {
        let app = launchAndLogin()

        let settings = app.buttons["Settings"].firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.click()
        let logout = app.buttons["setting-row-logout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 5))
        logout.click()

        let confirmButton = app.buttons["action-button-1"].firstMatch
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.click()

        XCTAssertTrue(app.staticTexts["login-title"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments.append("--ui-testing")
            app.launch()
        }
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()
        return app
    }

    @MainActor
    private func launchAndLogin() -> XCUIApplication {
        let app = launchApp()

        if app.descendants(matching: .any)["history-sidebar"].waitForExistence(timeout: 5) {
            return app
        }

        XCTAssertTrue(app.buttons["login-submit-button"].waitForExistence(timeout: 5))
        let privacy = app.checkBoxes["login-privacy-checkbox"]
        if privacy.exists, String(describing: privacy.value ?? "") == "0" {
            privacy.click()
        }
        app.buttons["login-submit-button"].click()

        XCTAssertTrue(app.descendants(matching: .any)["history-sidebar"].waitForExistence(timeout: 5))
        return app
    }
}
