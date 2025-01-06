//
//  AuthenticationViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseAuth

@MainActor
// View model for google sign in view
final class AuthenticationViewModel: ObservableObject{
    
    //Get google sign in credentials
    
    func signInGoogle () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        
    }
    // func signInApple () async throws {
    //    let helper = SignInAppleHelper()
    //    let tokens = try await helper.startSignInWithAppleFlow()
    //    let user = DBUser(auth: authDataResult)
    //    try await UserManager.shared.createNewUser(user: user)
        
    // }
    
    func signInAnonymous () async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        
    }
   
}
