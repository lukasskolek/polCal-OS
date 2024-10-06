//
//  AuthenticationManager.swift
//  polCal
//
//  Created by Lukas on 23/08/2024.
//

import Foundation
import FirebaseAuth

//this is our own model that takes just some information from the firebase authentification result to use inside our app
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init (user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    //this is a singleton, this is a bad design pattern, this should be solved by dependency injection one day.
    //https://www.youtube.com/watch?v=E3x07blYvdE
    static let shared = AuthenticationManager()
    
    private init() {  }
    
    //this function gets an authenticated user for when the app starts and the user has been signed in previously already and does not need to sign in this time
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            //I should handle this error a lot better, this is a bad placeholder solution
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    //signs the user out, this should have some error handling
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: SIGN IN EMAIL

extension AuthenticationManager {
    
    //this creates a new user
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    //This is a login/signin function for those who already have an account
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: SIGN IN SSO

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    func signIn(credential:AuthCredential) async throws -> AuthDataResultModel {
            let authDataResult = try await Auth.auth().signIn(with: credential)
            return AuthDataResultModel(user: authDataResult.user)
    }
}
