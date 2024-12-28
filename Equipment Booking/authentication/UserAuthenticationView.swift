//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
// View model for google sign in view
final class AuthenticationViewModel: ObservableObject{
    
    //Get google sign in credentials
    
    func signInGoogle () async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
    }
    
}

struct UserAuthenticationView: View {
    
    //initialise google sign in viewmodel
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                UserSignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                        
                    }
                }
                
            }
            
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in")
    }
}


struct UserAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                UserAuthenticationView(showSignInView: .constant(false))
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

//#Preview {
//    UserAuthenticationView()
//}
