//
//  ContentView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: EntryViewModel
    
    init() {
        // 실제 서비스 구현체를 생성합니다.
        let service = RealEntryService()
        // EntryViewModel을 StateObject로 초기화합니다.
        _viewModel = StateObject(wrappedValue: EntryViewModel(service: service))
    }

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
