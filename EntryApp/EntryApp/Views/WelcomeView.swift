//
//  WelcomeView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: EntryViewModel
    
    @State private var showingLoginView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("header_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                Text("Create stunning social graphics in seconds")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Continue with Google") {
                    // Implement Google login
                }
                .buttonStyle(SocialLoginButtonStyle())
                
                Button("Continue with Facebook") {
                    // Implement Facebook login
                }
                .buttonStyle(SocialLoginButtonStyle())
                
                Button("Continue with Apple") {
                    // Implement Apple login
                }
                .buttonStyle(SocialLoginButtonStyle())
                
                Button("Sign up for free") {
                    // Implement sign up
                }
                .buttonStyle(SocialLoginButtonStyle())
                
                Button("Have an account already? Log in.") {
                    showingLoginView = true
                }
                .foregroundColor(.blue)
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationDestination(isPresented: $showingLoginView) {
                LoginView()
            }
        }
    }
}
