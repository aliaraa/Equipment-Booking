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
    @Published var email: String = "" // Add this property
    @Published var password: String = "" // Include this if needed for sign-in
    @Published var authUser: AuthDataResultModel? = nil // Track authenticated user
    @Published var isAuthenticated: Bool = false  // Track authentication state
    
    
    func checkAuthenticationStatus() {
        if let user = Auth.auth().currentUser {
            self.authUser = AuthDataResultModel(user: user)
            self.isAuthenticated = true // ✅ Automatically set authentication status
        } else {
            self.isAuthenticated = false
        }
    }
    
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
//    func signInAnonymous() async throws {
//        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
//    }
    
    
    // Sign in with email and password / checking if user is already signed in
    func signIn() async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

//        // Debugging print statements
//        print("Attempting Firebase sign-in with:")
//        print("Email: \(normalizedEmail)")
//        print("Password Length: \(trimmedPassword.count)")

        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw NSError(domain: "InvalidInput", code: 422, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }

        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
            self.authUser = AuthDataResultModel(user: authDataResult.user)
            self.isAuthenticated = true
        } catch let error as NSError {
//            print("Firebase Error Code: \(error.code)")
//            print("Firebase Error Domain: \(error.domain)")
//            print("Firebase Error Message: \(error.localizedDescription)")

            // First, attempt to get the AuthErrorCode mapping
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
                // If `AuthErrorCode(_bridgedNSError: error)` fails, manually check the error code
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
    
    
    // Sign up new user an login immediately
    
    func signUpAndLogin(email: String, password: String) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            // Sign up the user
            let authDataResult = try await AuthenticationManager.shared.createUser(email: normalizedEmail, password: trimmedPassword)
            
            // Save authenticated user (should immediately sign them in)
            self.authUser = authDataResult
            
            // Set additional profile information
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
            
            // ✅ Mark user as authenticated
            self.isAuthenticated = true
        } catch {
            // Handle errors during sign-up
            print("Sign-up error: \(error.localizedDescription)")
            throw error
        }
    }
    
}

