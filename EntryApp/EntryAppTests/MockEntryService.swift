//
//  MockEntryService.swift
//  EntryAppTests
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation
import Combine

@testable import EntryApp

// MockEntryService: EntryService 프로토콜을 구현한 모의 서비스 클래스
class MockEntryService: EntryService {
    // 작업 성공 여부를 제어하는 변수
    var shouldSucceed = true
    // 모의 엔트리 데이터를 저장하는 배열
    var entries: [Entry] = []

    
    func setAuthToken(_ token: String?) {
        
    }
    // 모의 로그인 기능 구현
    func login(username: String, password: String) -> AnyPublisher<String, Error> {
        if shouldSucceed {
            // 성공 시 모의 토큰 반환
            return Just("mock_token").setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Login", code: 401, userInfo: nil)).eraseToAnyPublisher()
        }
    }
    
    func loginWithApple(code: String, idToken: String) -> AnyPublisher<String, Error> {
        if shouldSucceed {
            // 성공 시 모의 토큰 반환
            return Just("mock_token").setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Login", code: 401, userInfo: nil)).eraseToAnyPublisher()
        }
    }

    // 모의 엔트리 목록 가져오기 기능 구현
    func fetchEntries() -> AnyPublisher<[Entry], Error> {
        if shouldSucceed {
            // 성공 시 저장된 엔트리 목록 반환
            return Just(entries).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Fetch", code: 500, userInfo: nil)).eraseToAnyPublisher()
        }
    }

    // 모의 엔트리 생성 기능 구현
    func createEntry(title: String, content: String) -> AnyPublisher<Entry, Error> {
        if shouldSucceed {
            // 성공 시 새 엔트리 생성 및 저장
            let newEntry = Entry(id: UUID(), title: title, content: content)
            entries.append(newEntry)
            return Just(newEntry).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Create", code: 500, userInfo: nil)).eraseToAnyPublisher()
        }
    }

    // 모의 엔트리 업데이트 기능 구현
    func updateEntry(_ entry: Entry) -> AnyPublisher<Entry, Error> {
        if shouldSucceed {
            // 성공 시 엔트리 업데이트
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
                return Just(entry).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                // 엔트리를 찾지 못한 경우 에러 반환
                return Fail(error: NSError(domain: "Update", code: 404, userInfo: nil)).eraseToAnyPublisher()
            }
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Update", code: 500, userInfo: nil)).eraseToAnyPublisher()
        }
    }

    // 모의 엔트리 삭제 기능 구현
    func deleteEntry(_ entry: Entry) -> AnyPublisher<Void, Error> {
        if shouldSucceed {
            // 성공 시 엔트리 삭제
            entries.removeAll { $0.id == entry.id }
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            // 실패 시 에러 반환
            return Fail(error: NSError(domain: "Delete", code: 500, userInfo: nil)).eraseToAnyPublisher()
        }
    }
}
