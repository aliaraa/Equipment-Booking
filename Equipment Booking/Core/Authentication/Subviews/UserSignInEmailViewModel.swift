//
//  UserSignInEmailViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation

@MainActor

final class SignInEmailViewModel: ObservableObject {
    @Published var  email = ""
    @Published var  password = ""
    
    // User signup function
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        
    }
    
}
