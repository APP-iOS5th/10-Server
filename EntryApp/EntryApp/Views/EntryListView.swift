//
//  EntryListView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct EntryListView: View {
    @ObservedObject var viewModel: EntryViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.entries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry, viewModel: viewModel)) {
                        Text(entry.title)
                    }
                }
                .onDelete(perform: deleteEntry)
            }
            .navigationTitle("Entries")
            .navigationBarItems(trailing: Button("Add", action: addEntry))
            .navigationBarItems(leading: Button("Log out") {
                viewModel.logout()
            })
        }
        .onAppear {
            viewModel.fetchEntries()
        }
    }
    
    private func addEntry() {
        viewModel.createEntry(title: "New Entry", content: "Content")
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = viewModel.entries[index]
            viewModel.deleteEntry(entry)
        }
    }
}

#Preview {
    EntryListView(viewModel: EntryViewModel())
}
