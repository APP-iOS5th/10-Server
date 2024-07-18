//
//  EntryAppTests.swift
//  EntryAppTests
//
//  Created by Jungman Bae on 7/18/24.
//

import XCTest
import Combine

@testable import EntryApp

// EntryViewModelTests: EntryViewModel을 테스트하는 XCTestCase 하위 클래스
class EntryViewModelTests: XCTestCase {
    // 테스트할 EntryViewModel 인스턴스
    var viewModel: EntryViewModel!
    // 모의 서비스 인스턴스
    var mockService: MockEntryService!
    // Combine 구독을 저장할 Set
    var cancellables: Set<AnyCancellable>!

    // 각 테스트 케이스 실행 전에 호출되는 셋업 메서드
    override func setUp() {
        super.setUp()
        // MockEntryService 인스턴스 생성
        mockService = MockEntryService()
        // EntryViewModel 인스턴스 생성 (MockEntryService 주입)
        viewModel = EntryViewModel(service: mockService)
        // 빈 cancellables Set 생성
        cancellables = []
    }

    // 각 테스트 케이스 실행 후에 호출되는 정리 메서드
    override func tearDown() {
        // 테스트에 사용된 객체들을 해제합니다.
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    // 로그인 기능 테스트
    func testLogin() {
        // 비동기 작업 완료를 기다리기 위한 expectation 생성
        let expectation = XCTestExpectation(description: "Login")

        // isLoggedIn 상태 변화를 관찰
        viewModel.$isLoggedIn
            .dropFirst() // 초기값 무시
            .sink { isLoggedIn in
                // isLoggedIn이 true로 변경되었는지 확인
                XCTAssertTrue(isLoggedIn)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 로그인 메서드 호출
        viewModel.login(username: "testuser", password: "password")

        // expectation이 충족될 때까지 최대 1초 대기
        wait(for: [expectation], timeout: 1.0)
    }

    // 로그아웃 기능 테스트
    func testLogout() {
        // 초기 상태 설정: 로그인 상태, 엔트리 존재
        viewModel.isLoggedIn = true
        mockService.entries = [Entry(id: UUID(), title: "Test", content: "Content")]
        viewModel.entries = mockService.entries

        // 로그아웃 메서드 호출
        viewModel.logout()

        // 로그아웃 후 상태 검증
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertTrue(viewModel.entries.isEmpty)
    }

    // 엔트리 생성 기능 테스트
    func testCreateEntry() {
        // 비동기 작업 완료를 기다리기 위한 expectation 생성
        let expectation = XCTestExpectation(description: "Create Entry")

        // entries 배열 변화를 관찰
        viewModel.$entries
            .dropFirst() // 초기값 무시
            .sink { entries in
                // 새 엔트리가 올바르게 추가되었는지 확인
                XCTAssertEqual(entries.count, 1)
                XCTAssertEqual(entries.first?.title, "New Entry")
                XCTAssertEqual(entries.first?.content, "New Content")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 엔트리 생성 메서드 호출
        viewModel.createEntry(title: "New Entry", content: "New Content")

        // expectation이 충족될 때까지 최대 1초 대기
        wait(for: [expectation], timeout: 1.0)
    }

    // 엔트리 업데이트 기능 테스트
    func testUpdateEntry() {
        // 초기 상태 설정: 기존 엔트리 존재
        let entry = Entry(id: UUID(), title: "Original", content: "Original")
        mockService.entries = [entry]
        viewModel.entries = mockService.entries

        // 비동기 작업 완료를 기다리기 위한 expectation 생성
        let expectation = XCTestExpectation(description: "Update Entry")

        // entries 배열 변화를 관찰
        viewModel.$entries
            .dropFirst() // 초기값 무시
            .sink { entries in
                // 엔트리가 올바르게 업데이트되었는지 확인
                XCTAssertEqual(entries.count, 1)
                XCTAssertEqual(entries.first?.title, "Updated")
                XCTAssertEqual(entries.first?.content, "Updated")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 업데이트할 엔트리 생성
        let updatedEntry = Entry(id: entry.id, title: "Updated", content: "Updated")
        // 엔트리 업데이트 메서드 호출
        viewModel.updateEntry(updatedEntry)

        // expectation이 충족될 때까지 최대 1초 대기
        wait(for: [expectation], timeout: 1.0)
    }

    // 엔트리 삭제 기능 테스트
    func testDeleteEntry() {
        // 초기 상태 설정: 기존 엔트리 존재
        let entry = Entry(id: UUID(), title: "To Delete", content: "Content")
        mockService.entries = [entry]
        viewModel.entries = mockService.entries

        // 비동기 작업 완료를 기다리기 위한 expectation 생성
        let expectation = XCTestExpectation(description: "Delete Entry")

        // entries 배열 변화를 관찰
        viewModel.$entries
            .dropFirst() // 초기값 무시
            .sink { entries in
                // 엔트리가 올바르게 삭제되었는지 확인
                XCTAssertTrue(entries.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // 엔트리 삭제 메서드 호출
        viewModel.deleteEntry(entry)

        // expectation이 충족될 때까지 최대 1초 대기
        wait(for: [expectation], timeout: 1.0)
    }
}
