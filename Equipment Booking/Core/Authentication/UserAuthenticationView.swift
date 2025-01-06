//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices // for apple sign in

// apple sign in button using UIKit
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
    
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        
    }
    
    
}


struct UserAuthenticationView: View {
    
    //initialise google sign in viewmodel
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                        
                    }
                }
                
            }, label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                
            })
            
            
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
            
            SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                .allowsHitTesting(false)
                .frame(height: 55)
            
            
            
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
