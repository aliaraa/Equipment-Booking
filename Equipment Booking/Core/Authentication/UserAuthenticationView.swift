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
        VStack(spacing: 20){
            // Sign in anonymously test
            //            Button(action: {
            //                Task {
            //                    do {
            //                        try await viewModel.signInAnonymous()
            //                        showSignInView = false
            //                    } catch {
            //                        print(error)
            //
            //                    }
            //                }
            //
            //            }, label: {
            //                Text("Sign In Anonymously")
            //                    .font(.headline)
            //                    .foregroundColor(.white)
            //                    .frame(height: 55)
            //                    .frame(maxWidth: .infinity)
            //                    .background(Color.orange)
            //                    .cornerRadius(10)
            //
            //            })
            
            // Embedd userSignInEmaiView
            
            VStack(spacing: 10){
                UserSignInEmailView(showSignInView: $showSignInView)
            }
                        
            
            // Section devider
            HStack{
                Rectangle()
                    .frame(height: 1)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
                Text("or")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
            }
            .padding(.vertical, 8) // Add spacing around the divider
            
            // Google Sign In button
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
            // Apple Sign in button
            SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                .allowsHitTesting(false)
                .frame(height: 55)
                .padding(.top, 10)
            
            HStack{
                Text("Need a Profile?")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                NavigationLink(destination: UserSignInEmailView(showSignInView: $showSignInView)){
                    Text("Sign Up")
                        .foregroundColor(.blue)
                        .font(.subheadline)
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
