//
//  EntryService.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation
import Combine

// EntryService 프로토콜: 실제 서비스와 모의 서비스가 구현해야 할 메서드들을 정의합니다.
protocol EntryService {
    // 로그인 기능: 사용자 이름과 비밀번호를 받아 토큰을 반환합니다.
    func login(username: String, password: String) -> AnyPublisher<String, Error>
    // 엔트리 목록 가져오기 기능
    func fetchEntries() -> AnyPublisher<[Entry], Error>
    // 새 엔트리 생성 기능
    func createEntry(title: String, content: String) -> AnyPublisher<Entry, Error>
    // 엔트리 업데이트 기능
    func updateEntry(_ entry: Entry) -> AnyPublisher<Entry, Error>
    // 엔트리 삭제 기능
    func deleteEntry(_ entry: Entry) -> AnyPublisher<Void, Error>
}
