//
//  EntryDetailView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: EntryViewModel
    
    var body: some View {
        Form {
            TextField("Title", text: $viewModel.selectedEntry.title)
            TextEditor(text: $viewModel.selectedEntry.content)
        }
        .navigationTitle(viewModel.selectedEntry.title)
        .navigationBarItems(trailing: Button("Save") {
            viewModel.updateEntry(viewModel.selectedEntry)
            dismiss()
        })
    }
}
