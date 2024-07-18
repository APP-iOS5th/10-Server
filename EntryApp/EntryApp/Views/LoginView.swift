//
//  LoginView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var viewModel: EntryViewModel

    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Log in") {
                viewModel.login(username: username, password: password)
            }
            .buttonStyle(SocialLoginButtonStyle())
        }
        .padding()
        .navigationTitle("Log in")
        .onChange(of: viewModel.isLoggedIn) {
            if viewModel.isLoggedIn {
                dismiss()
            }
        }
    }
}

struct SocialLoginButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}
