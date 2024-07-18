//
//  ContentView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EntryViewModel()
    
    var body: some View {
        if viewModel.isLoggedIn {
            EntryListView(viewModel: viewModel)
        } else {
            WelcomeView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
