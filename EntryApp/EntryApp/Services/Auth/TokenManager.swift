//
//  TokenManager.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "AuthToken"
    private let userDefaults = UserDefaults.standard
    
    init() {
        // UI 테스트 시 토큰 초기화
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            deleteToken()
        }
    }

    func saveToken(_ token: String) {
        userDefaults.set(token, forKey: tokenKey)
        userDefaults.synchronize()
    }
    
    func getToken() -> String? {
        return userDefaults.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        userDefaults.removeObject(forKey: tokenKey)
    }
}
