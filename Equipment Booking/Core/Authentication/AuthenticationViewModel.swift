//
//  AuthenticationViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseAuth
import CryptoKit
import AuthenticationServices

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authUser: AuthDataResultModel? = nil
    @Published var isAuthenticated: Bool = false
    @Published var isEmailVerified: Bool = false // Track verification
    var currentNonce: String?
    
    func checkAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            self.authUser = AuthDataResultModel(user: user)
            self.isAuthenticated = true
            self.isEmailVerified = user.isEmailVerified
        } else {
            self.isAuthenticated = false
            self.isEmailVerified = false
        }
    }
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        self.authUser = authDataResult
        self.isAuthenticated = true
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw NSError(domain: "InvalidInput", code: 422, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
            self.authUser = AuthDataResultModel(user: authDataResult.user)
            self.isAuthenticated = true
            self.isEmailVerified = authDataResult.user.isEmailVerified
        } catch let error as NSError {
            // Error handling unchanged
            if let authErrorCode = AuthErrorCode(_bridgedNSError: error) {
                switch authErrorCode {
                case .userNotFound:
                    throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email not registered. Please sign up or try again."])
                case .invalidEmail:
                    throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email format. Please check and try again."])
                case .wrongPassword:
                    throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Try again."])
                default:
                    throw NSError(domain: "UnknownError", code: 500, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred."])
                }
            } else {
                switch error.code {
                case 17011: throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email not registered. Please sign up or try again."])
                case 17009: throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Try again."])
                case 17008: throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email format. Please check and try again."])
                case 17005: throw NSError(domain: "UserDisabled", code: 403, userInfo: [NSLocalizedDescriptionKey: "This account has been disabled."])
                default:
                    print("🔥 Failed to map error. Returning generic error.")
                    throw NSError(domain: "UnknownError", code: 500, userInfo: [NSLocalizedDescriptionKey: "An unexpected error occurred."])
                }
            }
        }
    }
    
    func signUpAndLogin(email: String, password: String) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(email: normalizedEmail, password: trimmedPassword)
            self.authUser = authDataResult
            self.isAuthenticated = false // User is signed out by createUser
            self.isEmailVerified = authDataResult.isEmailVerified
            
            // Send email verification (user is signed out, so we need to sign in briefly)
            let tempSignIn = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
            try await tempSignIn.user.sendEmailVerification()
            try await AuthenticationManager.shared.signOut() // Sign out again
        } catch {
            print("Sign-up error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func resendEmailVerification(email: String, password: String) async throws {
        // Sign in temporarily to resend verification
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
        try await authDataResult.user.sendEmailVerification()
        try await AuthenticationManager.shared.signOut()
    }
    
    func refreshEmailVerificationStatus(email: String, password: String) async throws -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
        try await authDataResult.user.reload()
        let isVerified = authDataResult.user.isEmailVerified
        try await AuthenticationManager.shared.signOut()
        self.isEmailVerified = isVerified
        return isVerified
    }
    
    func signInWithApple(result: Result<ASAuthorization, Error>, nonce: String) async throws {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw NSError(domain: "AppleSignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Apple ID token."])
            }
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            let authDataResult = try await AuthenticationManager.shared.signIn(credential: credential)
            self.authUser = authDataResult
            self.isAuthenticated = true
            var user = DBUser(auth: authDataResult)
            if let fullName = appleIDCredential.fullName {
                user.firstName = fullName.givenName
                user.lastName = fullName.familyName
            }
            try await UserManager.shared.createNewUser(user: user)
        case .failure(let error):
            throw error
        }
    }
}

// SignInWithAppleHelper

// Helper for generating nonce (unchanged)
struct SignInWithAppleHelper {
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { charset[Int($0) % charset.count] }
        return String(nonce)
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
