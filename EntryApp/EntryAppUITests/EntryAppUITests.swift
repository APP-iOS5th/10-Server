//
//  EntryAppUITests.swift
//  EntryAppUITests
//
//  Created by Jungman Bae on 7/18/24.
//

import XCTest

@testable import EntryApp

class EntryAppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // 앱 실행 시 TokenManager 초기화를 위한 launch argument 추가
        app.launchArguments.append("--uitesting")

        app.launch()
    }
    
    
    func testLoginFlow() throws {
        // "Have an account already? Log in." 버튼을 탭합니다.
        let loginButton = app.buttons["Have an account already? Log in."]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // 사용자 이름과 비밀번호를 입력합니다.
        let usernameTextField = app.textFields["Username"]
        let passwordSecureTextField = app.secureTextFields["Password"]

        usernameTextField.tap()
        usernameTextField.typeText("admin")

        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("secret")

        // 로그인 버튼을 탭합니다.
        let signInButton = app.buttons["Log in"]
        signInButton.tap()

        // 로그인 후 EntryListView로 이동했는지 확인합니다.
        let entriesNavBar = app.navigationBars["Entries"]
        let exists = entriesNavBar.waitForExistence(timeout: 10)
        
        if !exists {
            // 실패 시 더 자세한 정보를 얻기 위해 현재 화면의 요소들을 출력합니다.
            print("Current screen elements:")
            print(app.debugDescription)
        }

        XCTAssertTrue(exists, "Failed to navigate to Entries view after login")
    }

    func testCreateEntry(cleanup: Bool = true) throws {
        // 먼저 로그인합니다.
        try testLoginFlow()

        // "Add" 버튼을 탭합니다.
        app.navigationBars["Entries"].buttons["Add"].tap()

        // 처음 Add 페이지 진입시 New Entry 타이틀 표시
        XCTAssertEqual(app.navigationBars["New Entry"].exists, true)

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
        let entriesNavBar = app.staticTexts["Test Entry"]
        let exists = entriesNavBar.waitForExistence(timeout: 10)
        
        if !exists {
            // 실패 시 더 자세한 정보를 얻기 위해 현재 화면의 요소들을 출력합니다.
            print("Current screen elements:")
            print(app.debugDescription)
        }

        XCTAssertTrue(exists, "새로 생성된 엔트리가 목록에 표시되지 않음")
        // 완료 후 엔트리 삭제
        if cleanup {
            // 생성된 엔트리를 왼쪽으로 스와이프하여 삭제합니다.
            let entryCell = app.staticTexts["Test Entry"].firstMatch
            entryCell.swipeLeft()
            app.buttons["Delete"].tap()
            
            // 삭제된 엔트리가 목록에서 사라졌는지 확인합니다.
            XCTAssertFalse(app.staticTexts["Test Entry"].exists)
        }
    }

    func testUpdateEntry() throws {
        // 먼저 로그인하고 엔트리를 생성합니다.
        try testCreateEntry(cleanup: false)

        XCTAssertTrue(app.staticTexts["Test Entry"].waitForExistence(timeout: 5))

        // 생성된 엔트리를 탭합니다.
        app.staticTexts["Test Entry"].firstMatch.tap()

        // 제목을 수정합니다.
        let titleTextField = app.textFields.firstMatch
        titleTextField.tap()
        titleTextField.clearAndEnterText("Updated Test Entry")

        // "Save" 버튼을 탭합니다.
        app.navigationBars.buttons["Save"].tap()

        // 수정된 엔트리가 목록에 표시되는지 확인합니다.
        let entriesNavBar = app.staticTexts["Updated Test Entry"]
        let exists = entriesNavBar.waitForExistence(timeout: 10)
        
        if !exists {
            // 실패 시 더 자세한 정보를 얻기 위해 현재 화면의 요소들을 출력합니다.
            print("Current screen elements:")
            print(app.debugDescription)
        }

        XCTAssertTrue(exists, "수정된 엔트리가 목록에 표시되지 않음")
        // 생성된 엔트리를 왼쪽으로 스와이프하여 삭제합니다.
        let entryCell = app.staticTexts["Updated Test Entry"].firstMatch
        entryCell.swipeLeft()
        app.buttons["Delete"].tap()

        // 삭제된 엔트리가 목록에서 사라졌는지 확인합니다.
        XCTAssertFalse(app.staticTexts["Test Entry"].exists)

    }

    func testDeleteEntry() throws {
        // 먼저 로그인하고 엔트리를 생성합니다.
        try testCreateEntry(cleanup: false)
        // 생성된 엔트리를 왼쪽으로 스와이프하여 삭제합니다.
        let entryCell = app.staticTexts["Test Entry"].firstMatch
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
