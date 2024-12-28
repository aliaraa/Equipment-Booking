//
//  SignInGoogleHelper.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/28/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper {
    @MainActor
    
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInresult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInresult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
                
        let accessToken: String = gidSignInresult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}
