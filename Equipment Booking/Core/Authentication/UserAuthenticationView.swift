//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices // for Apple Sign-In


struct UserAuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailErrorMessage: String?
    @Binding var showSignInView: Bool
    @State private var showPassword: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToSignUp: Bool = false
    @State private var showInlineSignUp: Bool = false
    @State private var NavigateToTabsView: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    private var isSignInButtonEnabled: Bool {
        return emailErrorMessage == nil && !viewModel.password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title
                Text("Log in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                // Email Field with Validation
                CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { newFocus in
                        if newFocus != .email {
                            emailErrorMessage = ValidationHelper.validateEmail(viewModel.email)
                        } else {
                            emailErrorMessage = nil
                        }
                    }
                
                if let emailErrorMessage = emailErrorMessage {
                    Text(emailErrorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                // Password Field with Toggle Visibility
                CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                    .focused($focusedField, equals: .password)
                
                // Error Message Handling
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                        
                        if showInlineSignUp {
                            HStack {
                                Button("New User? Sign Up") {
                                    navigateToSignUp = true
                                }
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Sign-In Button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            errorMessage = nil
                            NavigateToTabsView = true
                        } catch let error as NSError {
                            handleSignInError(error)
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isSignInButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                .disabled(!isSignInButtonEnabled)
                
                // OR Separator
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Text("or")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 8)
                
                // Social Sign-In Options
                VStack(spacing: 20) {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                NavigateToTabsView = true
                            } catch {
                                print("Google Sign-In Error: \(error)")
                            }
                        }
                    }
                    .frame(height: 55)
                    
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .frame(height: 55)
                }
                
                // Sign-Up Button
                if !showInlineSignUp {
                    Button("Don't have an account? Sign Up") {
                        navigateToSignUp = true
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Navigation Links (Hidden)
                NavigationLink(destination: SignUpView().environmentObject(viewModel), isActive: $navigateToSignUp) {
                    EmptyView()
                }
                
                if #available(iOS 18.0, *) {
                    NavigationLink(destination: TabsView(), isActive: $NavigateToTabsView) {
                        EmptyView()
                    }
                } else {
                    // Fallback on earlier versions
                }
                
                Spacer()
                
                // Bottom Navigation Icons
                HStack {
                    if #available(iOS 18.0, *) {
                        NavigationLink(destination: TabsView()) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: UserProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $viewModel.email, onDismiss: { showForgotPassword = false })
            }
        }
    }
    
    // Function to Handle Sign-In Errors
    private func handleSignInError(_ error: NSError) {
        print("Sign-in error: \(error.domain) - \(error.localizedDescription)")
        switch error.code {
        case 404:
            errorMessage = "Email not registered. Please sign up or try again."
            showInlineSignUp = true
        case 401:
            errorMessage = "Incorrect password. Please try again."
            showInlineSignUp = true
        case 400:
            errorMessage = "Invalid email format. Please check and try again."
            showInlineSignUp = false
        default:
            errorMessage = "An unexpected error occurred."
            showInlineSignUp = true
        }
    }
}



// Apple Sign-In Button Wrapper
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}


#Preview {
    UserAuthenticationView(showSignInView: .constant(true))
}
