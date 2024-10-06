//
//  SignInWithEmailView.swift
//  polCal
//
//  Created by Lukas on 23/08/2024.
//

import SwiftUI

@MainActor
final class SignInWithEmailViewModel: ObservableObject  {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        //here I should build a more complete validation, and inform the user in case something is wrong, I can also instruct him here to create a stronger password if needed
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        // this variable can be called returnedUserData, or just underscore, as it is never used
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    func signIn() async throws {
        //here I should build a more complete validation, and inform the user in case something is wrong, I can also instruct him here to create a stronger password if needed
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        // this variable can be called returnedUserData, or just underscore, as it is never used
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInWithEmailView: View {
    
    @StateObject private var viewModel = SignInWithEmailViewModel()
    @Binding var showSignInView: Bool
     
    var body: some View {
        VStack{
            TextField("Email...", text: $viewModel.email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text: $viewModel.password)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button{
                Task{
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    }
                    catch {
                        print(error)
                    }
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    }
                    catch {
                        print(error)
                    }
                }
                
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    NavigationStack{
        SignInWithEmailView(showSignInView: .constant(false))
    }
}
