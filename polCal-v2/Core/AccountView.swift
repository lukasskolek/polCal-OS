//
//  AccountView.swift
//  polCal
//
//  Created by Lukas on 23/08/2024.
//

import SwiftUI

@MainActor
final class AccountViewModel: ObservableObject {
    
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            //this should also be a
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

struct AccountView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationStack{
            List {
                Button("Log out") {
                    Task{
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        }
                        catch{
                            //this should be handled properly somehow
                            print(error)
                        }
                    }
                }
                
                Button("Reset Password") {
                    Task{
                        do {
                            try await viewModel.resetPassword()
                            print("PASSWORD RESET!")
                        }
                        catch{
                            //this should be handled properly somehow
                            print(error)
                        }
                    }
                }
            }
            
            .navigationTitle("Your account")
        }
    }
}

#Preview {
    NavigationStack{
        AccountView(showSignInView: .constant(false))
    }
}
