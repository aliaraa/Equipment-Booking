//
//  AuthenticationViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authUser: AuthDataResultModel? = nil
    @Published var isAuthenticated: Bool = false
    
    func checkAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            self.authUser = AuthDataResultModel(user: user)
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        // Update authentication state
        self.authUser = authDataResult
        self.isAuthenticated = true // Set this to trigger navigation
        
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // Sign in with email and password
    func signIn() async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw NSError(domain: "InvalidInput", code: 422, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }

        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
            self.authUser = AuthDataResultModel(user: authDataResult.user)
            self.isAuthenticated = true // This triggers navigation
        } catch let error as NSError {
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
                case 17011: // userNotFound
                    throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "Email not registered. Please sign up or try again."])
                case 17009: // wrongPassword
                    throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Try again."])
                case 17008: // invalidEmail
                    throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email format. Please check and try again."])
                case 17005: // userDisabled
                    throw NSError(domain: "UserDisabled", code: 403, userInfo: [NSLocalizedDescriptionKey: "This account has been disabled."])
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
            self.isAuthenticated = true
            
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
        } catch {
            print("Sign-up error: \(error.localizedDescription)")
            throw error
        }
    }
}
