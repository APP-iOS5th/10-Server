//
//  Entry.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation

struct Entry: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    
    // Hashable 준수를 위한 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable 준수를 위한 구현 (Hashable은 Equatable을 상속받음)
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id
    }
}
