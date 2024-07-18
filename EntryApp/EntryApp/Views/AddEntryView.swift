//
//  AddEntryView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @State var content = ""
    @EnvironmentObject var viewModel: EntryViewModel
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextEditor(text: $content)
        }
        .navigationTitle(title.isEmpty ? "New Entry" : title)
        .navigationBarItems(trailing: Button("Save") {
            guard !title.isEmpty, !content.isEmpty else {
                print("title content empty")
                return
            }
            viewModel.createEntry(title: title, content: content)
            dismiss()
        })
    }
}

