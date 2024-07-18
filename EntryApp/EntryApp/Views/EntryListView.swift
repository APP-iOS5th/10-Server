//
//  EntryListView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct EntryListView: View {
    @EnvironmentObject var viewModel: EntryViewModel
    
    @State var isAdding = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.entries) { entry in
                    NavigationLink(value: entry) {
                        Text(entry.title)
                    }
                }
                .onDelete(perform: deleteEntry)
            }
            .navigationTitle("Entries")
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", action: addEntry)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Log out") {
                        viewModel.logout()
                    }
                }
            }
            .navigationDestination(isPresented: $isAdding) {
                AddEntryView()
            }
        }
        .onAppear {
            print("HERE!")
            viewModel.fetchEntries()
        }
    }
    
    private func addEntry() {
        self.isAdding.toggle()
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = viewModel.entries[index]
            viewModel.deleteEntry(entry)
        }
    }
}
