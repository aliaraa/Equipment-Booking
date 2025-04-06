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
    let dateCreated: Date?
    let isAdmin: Bool?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let address: String?
    let companyName: String?
    let profession: String?
    let isEmailVerified: Bool // Added
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
        self.dateCreated = user.metadata.creationDate
        self.isAdmin = nil
        self.firstName = nil
        self.lastName = nil
        self.phone = nil
        self.address = nil
        self.companyName = nil
        self.profession = nil
        self.isEmailVerified = user.isEmailVerified // Set from Firebase User
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - SIGN IN EMAIL/PASSWORD
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = AuthDataResultModel(user: authDataResult.user)
        try await UserManager.shared.createNewUser(user: DBUser(auth: user))
        try await Auth.auth().signOut()
        return user
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue:
                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Password is incorrect."])
            default:
                throw error
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// MARK: - SIGN IN SSO (GOOGLE & APPLE)
extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    // Generic sign-in method for SSO credentials (used by both Google and Apple)
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
