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
    
    
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    // Sign in with email and password / checking if user is already signed in
    
    func signIn() async throws {
        // Normalize email
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            // Attempt to sign in
            let authDataResult = try await AuthenticationManager.shared.signInUser(email: normalizedEmail, password: trimmedPassword)
            self.authUser = authDataResult
            self.isAuthenticated = true
            print("Sign-in successful for: \(authDataResult.email ?? "Unknown Email")")
        } catch let error as NSError {
            // Handle errors during login
            print("Firebase sign-in error: \(error.code) - \(error.localizedDescription)")
            throw error
        }
    }

    
//    func signIn() async throws {
//        // Normalize the email to be case-insensitive
//        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        do {
//            // Check if the user is already signed in
//            if let currentUser = Auth.auth().currentUser {
//                print("User is already signed in: \(currentUser.email ?? "Unknown Email")")
//                if currentUser.email?.lowercased() == normalizedEmail {
//                    // User is already signed in with the same email
//                    self.authUser = AuthDataResultModel(user: currentUser)
//                    return // Skip sign-in and stop execution
//                } else {
//                    // Sign out the currently signed-in user if the email doesn't match
//                    try await Auth.auth().signOut()
//                }
//            }
//            
//            // Attempt to sign in with email and password
//            let authDataResult = try await AuthenticationManager.shared.signInUser(email: normalizedEmail, password: trimmedPassword)
//            
//            // Save authenticated user
//            self.authUser = authDataResult
//            print("Sign-in successful for: \(authDataResult.email ?? "Unknown Email")")
//        } catch let error as NSError {
//            print("Firebase sign-in error: \(error.code) - \(error.localizedDescription)")
//            
//            // Handle specific errors
//            switch error.code {
//            case AuthErrorCode.userNotFound.rawValue:
//                throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "The entered email is not registered."])
//            case AuthErrorCode.wrongPassword.rawValue:
//                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
//            case AuthErrorCode.invalidCredential.rawValue:
//                throw NSError(domain: "InvalidCredential", code: 17004, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Please check your email and password."])
//            case AuthErrorCode.invalidEmail.rawValue:
//                throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "The entered email is not valid."])
//            default:
//                throw NSError(domain: "SignInError", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
//            }
//        }
//    }
    
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
    
//    func signIn() async throws {
//        // Normalize the email to be case-insensitive
//        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        do {
//            // Attempt to sign in using the AuthenticationManager
//            let authDataResult = try await AuthenticationManager.shared.signInUser(email: normalizedEmail, password: trimmedPassword)
//            self.authUser = authDataResult
//            print("Sign-in successful for: \(authDataResult.email ?? "Unknown Email")")
//        } catch let error as NSError {
//            print("Sign-in error: \(error.code) - \(error.localizedDescription)")
//            throw error // Propagate the error back to the view
//        }
//    }

    
//    func signIn() async throws {
//        // Normalize the email to be case-insensitive
//        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        do {
//            // Check if the user is already signed in
//            if let currentUser = Auth.auth().currentUser {
//                print("User is already signed in: \(currentUser.email ?? "Unknown Email")")
//                self.authUser = AuthDataResultModel(user: currentUser)
//                return // Skip sign-in
//            }
//
//            // Attempt to sign in with email and password
//            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
//
//            // Save authenticated user
//            self.authUser = AuthDataResultModel(user: authDataResult.user)
//            print("Sign-in successful for: \(authDataResult.user.email ?? "Unknown Email")")
//        } catch let error as NSError {
//            print("Firebase sign-in error: \(error.code) - \(error.localizedDescription)") // Debugging log
//
//            // Classify specific Firebase errors
//            switch error.code {
//            case AuthErrorCode.userNotFound.rawValue:
//                throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "The entered email is not registered."])
//            case AuthErrorCode.wrongPassword.rawValue:
//                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
//            case AuthErrorCode.invalidCredential.rawValue:
//                throw NSError(domain: "InvalidCredential", code: 17004, userInfo: [NSLocalizedDescriptionKey: "The entered email or password is invalid. Please check your credentials."])
//            case AuthErrorCode.invalidEmail.rawValue:
//                throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "The entered email is not valid."])
//            default:
//                throw NSError(domain: "SignInError", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
//            }
//        }
//    }

  
//    func signIn() async throws {
//        // Normalize the email to be case-insensitive
//        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        do {
//            // Check if the user is already signed in
//            if let currentUser = Auth.auth().currentUser {
//                print("User is already signed in: \(currentUser.email ?? "Unknown Email")")
//                self.authUser = AuthDataResultModel(user: currentUser)
//                return // No need to sign in again
//            }
//
//            // Attempt to sign in with the normalized email and password
//            let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: trimmedPassword)
//
//            // Save the authenticated user
//            self.authUser = AuthDataResultModel(user: authDataResult.user)
//
//            print("Sign-in successful for: \(authDataResult.user.email ?? "Unknown Email")")
//        } catch let error as NSError {
//            // Print error details for debugging
//            print("Firebase sign-in error: \(error.code) - \(error.localizedDescription)")
//
//            // Handle specific Firebase authentication errors
//            switch error.code {
//            case AuthErrorCode.userNotFound.rawValue:
//                // User not found
//                throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "The entered email is not registered."])
//            case AuthErrorCode.wrongPassword.rawValue:
//                // Incorrect password
//                throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
//            case AuthErrorCode.invalidCredential.rawValue:
//                // Invalid credential (common for 17004)
//                throw NSError(domain: "InvalidCredential", code: 17004, userInfo: [NSLocalizedDescriptionKey: "The entered email or password is invalid. Please check your credentials."])
//            case AuthErrorCode.invalidEmail.rawValue:
//                // Invalid email format
//                throw NSError(domain: "InvalidEmail", code: 400, userInfo: [NSLocalizedDescriptionKey: "The entered email is not valid."])
//            default:
//                // Handle other Firebase errors
//                throw NSError(domain: "SignInError", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
//            }
//        }
//    }

   
    
    
//    func signIn() async throws {
//            // Normalize the email to be case-insensitive
//            let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//
//            do {
//                // Attempt to sign in with the normalized email and password
//                let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
//
//                // Save the authenticated user
//                self.authUser = AuthDataResultModel(user: authDataResult.user)
//
//                print("Sign-in successful for: \(authDataResult.user.email ?? "Unknown Email")")
//            } catch let error as NSError {
//                // Print error details for debugging
//                print("Firebase sign-in error: \(error.code) - \(error.localizedDescription)")
//
//                // Handle specific Firebase authentication errors
//                if error.code == AuthErrorCode.userNotFound.rawValue {
//                    // User not found
//                    throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "The entered email is not registered."])
//                } else if error.code == AuthErrorCode.wrongPassword.rawValue {
//                    // Incorrect password
//                    throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
//                } else {
//                    // Handle other Firebase errors (e.g., malformed credentials)
//                    throw NSError(domain: "SignInError", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
//                }
//            }
//        }
    
//    func signIn() async throws {
//            // Normalize the email to be case-insensitive
//            let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//
//            // Check if user is already signed in
//            if let currentUser = Auth.auth().currentUser {
//                // User is already signed in
//                self.authUser = AuthDataResultModel(user: currentUser)
//                print("User is already signed in: \(currentUser.email ?? "Unknown Email")")
//
//                // Navigate to EquipmentListingView (handle in the View logic)
//                return
//            }
//
//            // Proceed with sign-in if not already signed in
//            do {
//                // Authenticate user with normalized email and password
//                let authDataResult = try await Auth.auth().signIn(withEmail: normalizedEmail, password: password)
//
//                // Save the authenticated user
//                self.authUser = AuthDataResultModel(user: authDataResult.user)
//
//                print("Sign-in successful for: \(authDataResult.user.email ?? "Unknown Email")")
//            } catch let error as NSError {
//                // Handle specific sign-in errors
//                if error.code == AuthErrorCode.userNotFound.rawValue {
//                    throw NSError(domain: "EmailNotRegistered", code: 404, userInfo: [NSLocalizedDescriptionKey: "The entered email is not registered."])
//                } else if error.code == AuthErrorCode.wrongPassword.rawValue {
//                    throw NSError(domain: "InvalidPassword", code: 401, userInfo: [NSLocalizedDescriptionKey: "The password you entered is incorrect."])
//                } else {
//                    throw NSError(domain: "SignInError", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
//                }
//            }
//        }

//    func signIn() async throws {
//        guard !email.isEmpty, !password.isEmpty else {
//            throw NSError(domain: "InputError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
//        }
//        try await AuthenticationManager.shared.signInUser(email: email, password: password)
//    }



//@MainActor
//// View model for google sign in view
//final class AuthenticationViewModel: ObservableObject{
//    
//    //Get google sign in credentials
//    
//    func signInGoogle () async throws {
//        let helper = SignInGoogleHelper()
//        let tokens = try await helper.signIn()
//        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
//        
//    }
//    // func signInApple () async throws {
//    //    let helper = SignInAppleHelper()
//    //    let tokens = try await helper.startSignInWithAppleFlow()
//    //    let user = DBUser(auth: authDataResult)
//    //    try await UserManager.shared.createNewUser(user: user)
//        
//    // }
//    
//    func signInAnonymous () async throws {
//        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
//        // try await UserManager.shared.createNewUser(auth: authDataResult)
//        
//    }
//   
//}
