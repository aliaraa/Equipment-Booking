//
//  SettingsViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseAuth

@MainActor

final class UserSettingsViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var authUser: AuthDataResultModel? = nil

    func loadCurrentUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)

            // Handle missing first name and last name
            if user?.firstName == nil || user?.lastName == nil {
                if let googleProfile = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "google.com" }) {
                    // Try to get names and photo from Google profile
                    let firstName = googleProfile.displayName?.components(separatedBy: " ").first
                    let lastName = googleProfile.displayName?.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let photoUrl = googleProfile.photoURL?.absoluteString

                    // Update user instance
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: photoUrl ?? authDataResult.photoUrl,
                        firstName: firstName ?? authDataResult.email,
                        lastName: lastName
                    )
                } else {
                    // Default to email if name is missing
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: authDataResult.photoUrl,
                        firstName: authDataResult.email,
                        lastName: nil
                    )
                }
            }
        } catch {
            print("Failed to load user: \(error.localizedDescription)")
            self.user = DBUser(
                userId: "unknown",
                email: "Unknown User",
                firstName: "Anonymous",
                lastName: "User"
            )
        }
    }
}

//final class UserSettingsViewModel: ObservableObject {
//    
//    @Published var authProviders: [AuthProvideroption] = []
//    @Published var authUser: AuthDataResultModel? = nil
//    
//    func loadAuthProviders() {
//        if let providers = try? AuthenticationManager.shared.getProviders() {
//            authProviders = providers
//        }
//        
//    }
//    
//    // Function to load authenticated user
//    
//    func loadauthUser() {
//        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//    }
//    
//    
//    func signOut() throws {
//        try AuthenticationManager.shared.signOut()
//    }
//    
//    func resetPassword () async throws {
//        let authUser =  try AuthenticationManager.shared.getAuthenticatedUser()
//        
//        guard let email = authUser.email else {
//            
//            throw URLError(.fileDoesNotExist)
//        }
//        try await AuthenticationManager.shared.resetPassword(email: email)
//        
//    }
//    
//    
//    func updateEmail () async throws {
//        let email = "test123@gmail.com"
//        try await AuthenticationManager.shared.updateEmail(email: email)
//        
//    }
//    
//    func updatePassword () async throws {
//        let password = "test123"
//        try await AuthenticationManager.shared.updatePassword(password: password)
//        
//    }
//    
//    func linkGoogleAccount() async throws {
//        let helper = SignInGoogleHelper()
//        let tokens = try await helper.signIn()
//        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
//        
//    }
//    
//    /*
//    func linkAppleAccount() async throws {
//        let helper = SignInAppleHelper()
//        let tokens = try await helper.signInWithAppleFlow()
//        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
//    }
//     */
//    
//    func linkEmailAccount() async throws {
//        let email = "test2@testing.com"
//        let password = "1234321"
//        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
//        
//    }
//    
//}
