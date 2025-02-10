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
// import TextFieldStyles // functions to format textfields


struct UserAuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailErrorMessage: String?
    @Binding var showSignInView: Bool
    @State private var showPassword: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToSignUp: Bool = false // Controls navigation to SignUpView
    @State private var showInlineSignUp: Bool = false // Determines if inline Sign-Up appears
    @State private var navigateToEquipmentListing: Bool = false // Navigation trigger for EquipmentListingView
    
    // Focus tracking
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    // Computed property to enable/disable Sign Up button
    private var isSignInButtonEnabled: Bool {
        return emailErrorMessage == nil &&
               !viewModel.password.isEmpty
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Welcome Message
                Text("Log in")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                // Email and Password Fields
                
                // Email Field (Validate when moving focus away)
                CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                    .focused($focusedField, equals: .email)
                    .onChange(of: focusedField) { newFocus in
                        if newFocus != .email {
                            emailErrorMessage = ValidationHelper.validateEmail(viewModel.email)
                        }
                        else {
                                    // Reset error message when focus returns to the email field
                                    emailErrorMessage = nil
                                }
                    }

                if let emailErrorMessage = emailErrorMessage {
                    Text(emailErrorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                

                // Password Field (No inline validation)
                CustomSecureField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                    .focused($focusedField, equals: .password)
                
             
                // Login Error Message & Inline Sign-Up Suggestion
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.bottom, 5)
                        
                        if showInlineSignUp {
                            HStack {
                                Button("New User? Sign Up") {
                                    navigateToSignUp = true // Trigger navigation
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
                
                // Sign In Button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            errorMessage = nil // Clear any previous errors
                            navigateToEquipmentListing = true // Navigate to EquipmentListingView
                        } catch let error as NSError {
                            print("Sign-in error: \(error.domain) - \(error.localizedDescription)")
                            
                            switch error.code {
                            case 404: // Email not registered
                                errorMessage = "Email not registered. Please sign up or try again."
                                showInlineSignUp = true
                            case 401: // Wrong password
                                errorMessage = "Incorrect password. Please try again."
                                showInlineSignUp = true
                            case 400: // Invalid email format
                                errorMessage = "Invalid email format. Please check and try again."
                                showInlineSignUp = false
                            default:
                                errorMessage = "An unexpected error occurred."
                                showInlineSignUp = false
                            }
                        }
                        
                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isSignInButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
//                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(!isSignInButtonEnabled)
                

                 // Divider
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
                
                // Google and Apple Sign-In Buttons
                VStack(spacing: 20) {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                navigateToEquipmentListing = true // Navigate after Google sign-in
                            } catch {
                                print("Google Sign-In Error: \(error)")
                            }
                        }
                    }
                    .frame(height: 55)
                    
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .frame(height: 55)
                }
                
                // Bottom Sign-Up Button (Hidden if inline sign-up is shown)
                // Bottom Sign-Up Button (Hidden if inline sign-up is shown)
                if !showInlineSignUp {
                    Button("Don't have an account? Sign Up") {
                        navigateToSignUp = true // Trigger navigation
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                
                
                Spacer()
                
                // Navigation to SignUpView
                NavigationLink(destination: SignUpView().environmentObject(viewModel), isActive: $navigateToSignUp) {
                    EmptyView()
                }
                
                Spacer()
                
                // Footer with Home and User Profile buttons
                HStack {
                    NavigationLink(destination: EquipmentListingView(), isActive: $navigateToEquipmentListing) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(destination: EquipmentListingView()) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
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
            //.navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $viewModel.email, onDismiss: { showForgotPassword = false })
            }
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
