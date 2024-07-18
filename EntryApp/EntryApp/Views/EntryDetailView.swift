//
//  EntryDetailView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct EntryDetailView: View {
    @State var entry: Entry
    @ObservedObject var viewModel: EntryViewModel
    
    var body: some View {
        Form {
            TextField("Title", text: $entry.title)
            TextEditor(text: $entry.content)
        }
        .navigationTitle(entry.title)
        .navigationBarItems(trailing: Button("Save") {
            viewModel.updateEntry(entry)
        })
    }
}
