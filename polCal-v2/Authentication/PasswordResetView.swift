//
//  PasswordResetView.swift
//  polCal
//
//  Created by Lukas on 26/08/2024.
//

import SwiftUI

@MainActor
final class PasswordResetViewModel: ObservableObject  {
    
    @Published var email = ""
    
    func resetPassword(email: String) async throws {
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
}

struct PasswordResetView: View {
    
    @StateObject private var viewModel = PasswordResetViewModel()
     
    var body: some View {
        VStack{
            TextField("Email...", text: $viewModel.email)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button{
                Task{
                    do {
                        try await viewModel.resetPassword(email: viewModel.email)
                        return
                    }
                    catch {
                        print("fasf error")
                    }
                }
                
            } label: {
                Text("Send")
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
        .navigationTitle("Reset your password")
    }
}

#Preview {
    NavigationStack{
        PasswordResetView()
    }
}
