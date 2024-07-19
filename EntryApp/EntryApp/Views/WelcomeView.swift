//
//  WelcomeView.swift
//  EntryApp
//
//  Created by Jungman Bae on 7/18/24.
//

import SwiftUI
import AuthenticationServices

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
                
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            print("Apple Login Successful")
                            switch authResults.credential{
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                // 계정 정보 가져오기
                                if let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8),
                                   let code = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) {
                                    viewModel.loginWithApple(code: code, idToken: idToken)
                                } else {
                                    print("Apple login failed")
                                }
                                
                            default:
                                break
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                            print("error")
                        }
                    }
                )
                .frame(width : UIScreen.main.bounds.width * 0.9, height:50)
                .cornerRadius(5)
                
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
