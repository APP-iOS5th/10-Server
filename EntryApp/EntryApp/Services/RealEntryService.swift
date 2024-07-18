//
//  RealEntryService.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//
import Foundation
import Combine

// MARK: - 실제 EntryService 구현

// RealEntryService: EntryService 프로토콜을 실제로 구현한 클래스입니다.
// 이 클래스는 실제 서버와 통신하여 데이터를 주고받습니다.
class RealEntryService: EntryService {
    // 서버의 기본 URL입니다.
    private let baseURL = "http://127.0.0.1:8080/api"
    // URLSession 인스턴스입니다. 네트워크 요청에 사용됩니다.
    private let session: URLSession
    // 현재 인증 토큰을 저장합니다. 로그인 후 설정되며, 이후 요청에 사용됩니다.
    private var authToken: String?

    // 생성자: URLSession을 주입받아 초기화합니다. 기본값으로 shared 세션을 사용합니다.
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - 네트워크 요청 헬퍼 메서드

    // 인증 헤더를 포함한 URLRequest를 생성하는 메서드입니다.
    private func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // 네트워크 요청을 수행하고 결과를 디코딩하는 제네릭 메서드입니다.
    private func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // MARK: - EntryService 프로토콜 메서드 구현
    
    // 저장된 토큰을 불러옵니다.
    func setAuthToken(_ token: String?) {
        if let token = token {
            authToken = token
        }
    }


    // 로그인 기능을 구현합니다.
    func login(username: String, password: String) -> AnyPublisher<String, Error> {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 로그인 정보를 JSON으로 인코딩합니다.
        let body = ["name": username, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> String in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                
                guard let token = String(data: data, encoding: .utf8) else {
                    throw URLError(.cannotParseResponse)
                }
                
                return token
            }
            .handleEvents(receiveOutput: { [weak self] token in
                self?.authToken = token // 받은 토큰을 저장합니다.
            })
            .eraseToAnyPublisher()
    }

    // 엔트리 목록을 가져오는 기능을 구현합니다.
    func fetchEntries() -> AnyPublisher<[Entry], Error> {
        let url = URL(string: "\(baseURL)/entries")!
        let request = authorizedRequest(url: url)
        return performRequest(request)
    }

    // 새 엔트리를 생성하는 기능을 구현합니다.
    func createEntry(title: String, content: String) -> AnyPublisher<Entry, Error> {
        let url = URL(string: "\(baseURL)/entries")!
        var request = authorizedRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 새 엔트리 정보를 JSON으로 인코딩합니다.
        let body = ["title": title, "content": content]
        request.httpBody = try? JSONEncoder().encode(body)

        return performRequest(request)
    }

    // 엔트리를 업데이트하는 기능을 구현합니다.
    func updateEntry(_ entry: Entry) -> AnyPublisher<Entry, Error> {
        let url = URL(string: "\(baseURL)/entries/\(entry.id)")!
        var request = authorizedRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 업데이트할 엔트리 정보를 JSON으로 인코딩합니다.
        request.httpBody = try? JSONEncoder().encode(entry)

        return performRequest(request)
    }

    // 엔트리를 삭제하는 기능을 구현합니다.
    func deleteEntry(_ entry: Entry) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseURL)/entries/\(entry.id)")!
        var request = authorizedRequest(url: url)
        request.httpMethod = "DELETE"

        return session.dataTaskPublisher(for: request)
            .map { _ in () } // 성공 시 Void를 반환합니다.
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
