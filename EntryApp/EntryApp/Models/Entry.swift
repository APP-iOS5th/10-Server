//
//  Entry.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import Foundation

struct Entry: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
}
