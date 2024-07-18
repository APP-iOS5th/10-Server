//
//  EntryAppUITestsLaunchTests.swift
//  EntryAppUITests
//
//  Created by Jungman Bae on 7/18/24.
//

import XCTest

final class EntryAppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 론치 화면이 제대로 표시되는지 확인합니다.
        let launchScreenTitle = app.staticTexts["Create stunning social graphics in seconds"]
        XCTAssertTrue(launchScreenTitle.waitForExistence(timeout: 5))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
