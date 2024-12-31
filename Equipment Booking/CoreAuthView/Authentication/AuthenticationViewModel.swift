//
//  AuthenticationViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation

@MainActor
// View model for google sign in view
final class AuthenticationViewModel: ObservableObject{
    
    //Get google sign in credentials
    
    func signInGoogle () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
    }
    // func signInApple () async throws {
    //    let helper = SignInAppleHelper()
    //    let tokens = try await helper.startSignInWithAppleFlow()
    //    try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        
    // }
    
    func signInAnonymous () async throws {
        try await AuthenticationManager.shared.signInAnonymous()
        
    }
    
    
    
}
