//
//  AuthenticationManagement.swift
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




final class authenticationManager {
    static let shared  = authenticationManager()
    private init () {}
    
    // Function to get user
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // Function to create a user
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    //Function to sign out
    
    func singOut () throws {
        try Auth.auth().signOut()
        
    }
    
    
}
