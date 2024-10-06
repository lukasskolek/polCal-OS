//
//  AuthenticationView.swift
//  polCal
//
//  Created by Lukas on 23/08/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

@MainActor
final class AuthenticationViewModel: ObservableObject{
    
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            //I should create a custom error here
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.cancelled)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                SignInWithEmailView(showSignInView: $showSignInView)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill") // Make sure you have this image in your assets
                        .resizable()
                        .frame(width: 20, height: 15)
                        .foregroundColor(.white)
                    Text("Sign in with email")
                        .font(.custom("Roboto-Medium", size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                     
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(20)
            }
            GoogleSignInSpecialButton {
                Task{
                    do{
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        //I should do a proper error handling here
                        print("Fuck something with the google sign in didn't work")
                    }
                    
                }
            }
            
            
            NavigationLink{
                PasswordResetView()
            } label: {
                Text("Forgot password?")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
            }
            Spacer()
            
        }
        .padding()
        .navigationTitle("Welcome to polCal")
    }
}

#Preview {
    NavigationStack{
        AuthenticationView(showSignInView: .constant(false))
    }
}
