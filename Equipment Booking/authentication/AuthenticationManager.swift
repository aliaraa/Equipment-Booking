//
//  AuthenticationManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import Foundation
import Firebase
import FirebaseAuth
// import FirebaseFirestore

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
    @State private var firstname: String = "Loading..." // Default placeholder for user name
    private let db = Firestore.firestore()
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
    
    // Function to fetch user details from firestore db
    func fetchUserNames(){
        guard let user = Auth.auth().currentUser else {
            print("No user currently signed in")
            return
        }
        let userUID = user.uid // get the signed in user's UID from authentication
        let userDocRef = db.collection("users").document(userUID) //get corresponding user details from firebase users collection
        
        userDocRef.getDocument{ document, error in
            if let error = error {
                print ("Error fetching user details: \(error.localizedDescription)")
                self.firstName = "Unkown " //if no use info found
                return
            }
            
            if let document = document, document.exists {
                if let fetchedFirstname = document.data()?["firsname"] as String {
                    self.firstname = fetchedFirstname
                }
                else{
                    self.firstname = "No Name"
                }
            } else {
                print("Document does not exist for user \(userUID).")
                self.firstname = "Unkown"
                
            }
        }
    }
        
    
    
}
