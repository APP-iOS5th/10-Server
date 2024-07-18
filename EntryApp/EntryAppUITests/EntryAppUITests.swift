//
//  EntryAppUITests.swift
//  EntryAppUITests
//
//  Created by Jungman Bae on 7/18/24.
//

import XCTest

class EntryAppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testLoginFlow() throws {
        // "Have an account already? Log in." 버튼을 탭합니다.
        app.buttons["Have an account already? Log in."].tap()

        // 사용자 이름과 비밀번호를 입력합니다.
        let usernameTextField = app.textFields["Username"]
        let passwordSecureTextField = app.secureTextFields["Password"]

        usernameTextField.tap()
        usernameTextField.typeText("admin")

        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("secret")

        // 로그인 버튼을 탭합니다.
        app.buttons["Log in"].tap()

        // 로그인 후 EntryListView로 이동했는지 확인합니다.
        XCTAssertTrue(app.navigationBars["Entries"].exists)
    }

    func testCreateEntry() throws {
        // 먼저 로그인합니다.
        try testLoginFlow()

        // "Add" 버튼을 탭합니다.
        app.navigationBars["Entries"].buttons["Add"].tap()

        // 제목과 내용을 입력합니다.
        let titleTextField = app.textFields.firstMatch
        let contentTextView = app.textViews.firstMatch

        titleTextField.tap()
        titleTextField.typeText("Test Entry")

        contentTextView.tap()
        contentTextView.typeText("This is a test entry content.")

        // "Save" 버튼을 탭합니다.
        app.navigationBars.buttons["Save"].tap()

        // 새로 생성된 엔트리가 목록에 표시되는지 확인합니다.
        XCTAssertTrue(app.staticTexts["Test Entry"].exists)
    }

    func testUpdateEntry() throws {
        // 먼저 로그인하고 엔트리를 생성합니다.
        try testCreateEntry()

        // 생성된 엔트리를 탭합니다.
        app.staticTexts["Test Entry"].tap()

        // 제목을 수정합니다.
        let titleTextField = app.textFields.firstMatch
        titleTextField.tap()
        titleTextField.clearAndEnterText("Updated Test Entry")

        // "Save" 버튼을 탭합니다.
        app.navigationBars.buttons["Save"].tap()

        // 수정된 엔트리가 목록에 표시되는지 확인합니다.
        XCTAssertTrue(app.staticTexts["Updated Test Entry"].exists)
    }

    func testDeleteEntry() throws {
        // 먼저 로그인하고 엔트리를 생성합니다.
        try testCreateEntry()

        // 생성된 엔트리를 왼쪽으로 스와이프하여 삭제합니다.
        let entryCell = app.staticTexts["Test Entry"]
        entryCell.swipeLeft()
        app.buttons["Delete"].tap()

        // 삭제된 엔트리가 목록에서 사라졌는지 확인합니다.
        XCTAssertFalse(app.staticTexts["Test Entry"].exists)
    }

    func testLogout() throws {
        // 먼저 로그인합니다.
        try testLoginFlow()

        // "Log out" 버튼을 탭합니다.
        app.navigationBars["Entries"].buttons["Log out"].tap()

        // 로그아웃 후 WelcomeView로 돌아왔는지 확인합니다.
        XCTAssertTrue(app.staticTexts["Create stunning social graphics in seconds"].exists)
    }
}

extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
