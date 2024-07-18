//
//  EntryViewModel.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation
import Combine

// EntryViewModel: 앱의 비즈니스 로직을 처리하는 뷰모델 클래스
class EntryViewModel: ObservableObject {
    // 엔트리 목록을 저장하고 변경을 관찰할 수 있는 @Published 프로퍼티
    @Published var entries: [Entry] = []
    // 로그인 상태를 저장하고 변경을 관찰할 수 있는 @Published 프로퍼티
    @Published var isLoggedIn = false
    // EntryService 프로토콜을 따르는 서비스 객체
    private var service: EntryService
    // Combine 구독을 저장하는 Set
    private var cancellables = Set<AnyCancellable>()

    // 생성자: EntryService를 주입받아 초기화합니다.
    init(service: EntryService) {
        self.service = service
    }

    // 로그인 기능
    func login(username: String, password: String) {
        service.login(username: username, password: password)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        // 로그인 실패 시 에러 처리
                        print("Login failed: \(error.localizedDescription)")
                        self?.isLoggedIn = false
                    }
                },
                receiveValue: { [weak self] (token: String) in
                    // 로그인 성공 시 isLoggedIn을 true로 설정
                    self?.isLoggedIn = true
                    print("Login successful. Token: \(token)")
                }
            )
            .store(in: &cancellables)
    }

    // 로그아웃 기능
    func logout() {
        // 로그아웃 시 isLoggedIn을 false로 설정하고 엔트리 목록을 비웁니다.
        isLoggedIn = false
        entries = []
    }

    // 엔트리 목록 가져오기 기능
    func fetchEntries() {
        service.fetchEntries()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] fetchedEntries in
                // 가져온 엔트리 목록으로 entries를 업데이트합니다.
                self?.entries = fetchedEntries
            })
            .store(in: &cancellables)
    }

    // 새 엔트리 생성 기능
    func createEntry(title: String, content: String) {
        service.createEntry(title: title, content: content)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] newEntry in
                // 새로 생성된 엔트리를 entries 배열에 추가합니다.
                self?.entries.append(newEntry)
            })
            .store(in: &cancellables)
    }

    // 엔트리 업데이트 기능
    func updateEntry(_ entry: Entry) {
        service.updateEntry(entry)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (updatedEntry: Entry) in
                    if let index = self?.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        self?.entries[index] = updatedEntry
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // 엔트리 삭제 기능
    func deleteEntry(_ entry: Entry) {
        service.deleteEntry(entry)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                // 삭제된 엔트리를 entries 배열에서 제거합니다.
                self?.entries.removeAll { $0.id == entry.id }
            })
            .store(in: &cancellables)
    }
}
