//
//  EntryViewModel.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation
import Combine

class EntryViewModel: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var isLoggedIn = false
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://localhost:8080/api"
    private var authToken: String?
    
    func login(username: String, password: String) {
        let loginRequest = LoginRequest(name: username, password: password)
        
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            print("Error encoding login request: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: String.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Login error: \(error)")
                }
            } receiveValue: { [weak self] token in
                self?.authToken = token
                self?.isLoggedIn = true
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        authToken = nil
        isLoggedIn = false
        entries = []
    }
    
    func fetchEntries() {
        guard let url = URL(string: "\(baseURL)/entries") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Entry].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Fetch entries error: \(error)")
                }
            } receiveValue: { [weak self] entries in
                self?.entries = entries
            }
            .store(in: &cancellables)
    }
    
    func createEntry(title: String, content: String) {
        let newEntry = Entry(id: UUID(), title: title, content: content)
        
        guard let url = URL(string: "\(baseURL)/entries") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(newEntry)
        } catch {
            print("Error encoding new entry: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Entry.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Create entry error: \(error)")
                }
            } receiveValue: { [weak self] entry in
                self?.entries.append(entry)
            }
            .store(in: &cancellables)
    }
    
    func updateEntry(_ entry: Entry) {
        guard let url = URL(string: "\(baseURL)/entries/\(entry.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(entry)
        } catch {
            print("Error encoding updated entry: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Entry.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Update entry error: \(error)")
                }
            } receiveValue: { [weak self] updatedEntry in
                if let index = self?.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                    self?.entries[index] = updatedEntry
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteEntry(_ entry: Entry) {
        guard let url = URL(string: "\(baseURL)/entries/\(entry.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Delete entry error: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.entries.removeAll { $0.id == entry.id }
            }
            .store(in: &cancellables)
    }
}
