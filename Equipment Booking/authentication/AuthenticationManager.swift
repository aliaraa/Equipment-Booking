//
//  AuthenticationManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
    
}


final class AuthenticationManager {
    static let shared  = AuthenticationManager()
    private init () {}
    
    // Function to get user
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // Function to create a user
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult 
    func signInUser (email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
        
    }
    //Function to reser password
    func resetPassword (email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    //Function to update password
    func updatePassword (password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError (.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    //Function to update email
    func updateEmail (email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError (.badServerResponse)
        }
        try await user.updateEmail(to: email) //deprecated function
    }
    
    
    //Function to sign out
    
    func signOut () throws {
        try Auth.auth().signOut()
        
    }
    
    
}
