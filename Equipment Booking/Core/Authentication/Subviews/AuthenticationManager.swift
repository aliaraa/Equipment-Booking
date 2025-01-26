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
    let isAnonymous: Bool
    
    // for profile data fetching
    
    // let userId : String
    let dateCreated : Date?
    let isAdmin : Bool?
    let firstName : String?
    let lastName : String?
    let phone : String?
    let address : String?
    let companyName :String?
    let profession : String?
    
    
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
 
        
        //self.userId = user.userId
        self.dateCreated = user.metadata.creationDate
        self.isAdmin = nil
        self.firstName = nil
        self.lastName = nil
        self.phone = nil
        self.address = nil
        self.companyName = nil
        self.profession = nil
        
    }
    
}

enum AuthProvideroption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
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
    
    // Function to get provider service for sign in
    // allows to select what to show after successful login
    
    
    
    // Provider function (login method)
    
    func getProviders() throws  -> [AuthProvideroption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProvideroption] = []
        for provider in providerData {
            if  let option = AuthProvideroption(rawValue: provider.providerID) {
                providers.append(option)
                
            } else {
                assertionFailure("Provide option not found: \(provider.providerID)")
            }
            //
        }
        return providers
        
    }
    
    
    //Function to sign out
    
    func signOut () throws {
        try Auth.auth().signOut()
        
    }
    
}

// MARK: SIGN IN EMAIL

extension AuthenticationManager{
    // creates a user , not leaving the user logged in.
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        // Temporarily create a user
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)

        // Save user details to the database (optional, depends on your app's requirements)
        let user = AuthDataResultModel(user: authDataResult.user)
        
        // Add the user to your Firestore database or wherever you're managing users
        let userModel = AuthDataResultModel(user: authDataResult.user)
        try await UserManager.shared.createNewUser(user: DBUser(auth: userModel))

        //try await UserManager.shared.createNewUser(user: DBUser(auth: authDataResult.user))
                
        
        // Immediately sign the user out after creation
        try await Auth.auth().signOut()

        return user // Return user details without leaving them signed in
    }
    
//    @discardableResult
//    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
//        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
//        return AuthDataResultModel(user: authDataResult.user)
//    }
    
// Sign in user function with security verification
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        // Normalize email
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check if email exists in Firebase
        let methods = try await Auth.auth().fetchSignInMethods(forEmail: normalizedEmail)
        if methods.isEmpty {
            // Throw error if email is not registered
            throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email is not registered."])
        }
        
        do {
            // Attempt to sign in with the normalized email and password
            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch let error as NSError {
            // Handle specific Firebase errors
            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue:
                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Password is incorrect."])
            case AuthErrorCode.invalidCredential.rawValue:
                throw NSError(domain: "InvalidCredential", code: 17004, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Please check your email and password."])
            default:
                // Re-throw unknown errors
                throw error
            }
        }
    }

    
//    @discardableResult
//    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
//        // Check if email exists in Firebase
//        let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
//        if methods.isEmpty {
//            // Throw error if email is not registered
//            throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email is not registered."])
//        }
//        
//        do {
//            // Attempt password-based login
//            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
//            return AuthDataResultModel(user: authDataResult.user)
//        } catch let error as NSError {
//            // Handle specific Firebase errors
//            switch error.code {
//            case AuthErrorCode.wrongPassword.rawValue:
//                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Password is incorrect."])
//            case AuthErrorCode.invalidCredential.rawValue:
//                throw NSError(domain: "InvalidCredential", code: 17004, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Please check your email and password."])
//            default:
//                // Re-throw unknown errors
//                throw error
//            }
//        }
//    }

    
//    @discardableResult
//        func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
//            // Check if email exists in Firebase
//            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
//            if methods.isEmpty {
//                // Throw error if email is not registered
//                throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email is not registered."])
//            }
//            
//            do {
//                // Attempt password-based login
//                let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
//                return AuthDataResultModel(user: authDataResult.user)
//            } catch {
//                // Handle incorrect password
//                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Password is incorrect."])
//            }
//        }
    
//    @discardableResult
//    func signInUser (email: String, password: String) async throws -> AuthDataResultModel {
//        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
//        return AuthDataResultModel(user: authDataResult.user)
//        
//    }
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
        // try await user.updateEmail(to: email) //deprecated function
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
}

// MARK: SIGN IN SSO

extension AuthenticationManager{
    
    @discardableResult
    // function to sign in with google using auth credentials
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
        
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
        
    }

}

// MARK: SIGN IN ANONYMOUSLY

extension AuthenticationManager{
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    // Functions to link anonymously signed in user id with already signed in credentials (email/Password, google, apple accounts)
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
        return try await linkCredential(credential: credential)
    }

/*
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProvideroption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        
        return try await linkCredential(credential: credential)
    }
*/
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
}
    


