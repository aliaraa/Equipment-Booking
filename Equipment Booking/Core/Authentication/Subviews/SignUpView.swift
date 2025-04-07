//
//  SignUpView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/12/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var emailErrorMessage: String?
    @State private var confirmPasswordErrorMessage: String?
    @State private var showVerificationPrompt: Bool = false
    @State private var verificationMessage: String?
    @State private var isCheckingVerification: Bool = false // For progress indicator
    @State private var navigateToTabsView: Bool = false
    @State private var selectedTab: String? = "search"
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    private var isSignUpButtonEnabled: Bool {
        return emailErrorMessage == nil &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        confirmPasswordErrorMessage == nil
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(Color(UIColor.darkGray))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !showVerificationPrompt {
                    // Sign-up form
                    Text("Create Your Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                        .focused($focusedField, equals: .email)
                        .onChange(of: focusedField) { newFocus in
                            if newFocus != .email {
                                emailErrorMessage = ValidationHelper.validateEmail(email)
                            } else {
                                emailErrorMessage = nil
                            }
                        }
                    
                    if let emailErrorMessage = emailErrorMessage {
                        Text(emailErrorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    
                    CustomSecureField(icon: "lock", placeholder: "Password", text: $password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                        .focused($focusedField, equals: .password)
                    
                    CustomSecureField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: !showConfirmPassword, toggle: { showConfirmPassword.toggle() })
                        .focused($focusedField, equals: .confirmPassword)
                        .onChange(of: confirmPassword) { _ in
                            confirmPasswordErrorMessage = ValidationHelper.validateConfirmPassword(password: password, confirmPassword: confirmPassword)
                        }
                    
                    if let confirmPasswordErrorMessage = confirmPasswordErrorMessage {
                        Text(confirmPasswordErrorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    
                    Button(action: handleSignUp) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(isSignUpButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(!isSignUpButtonEnabled)
                } else {
                    // Custom verification prompt
                    VStack(spacing: 20) {
                        Text("Verify Your Email")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)
                        
                        Text("A verification email has been sent to \(email). Please check your inbox (and spam folder) and click the link to verify your email.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .font(.body)
                        
                        if let message = verificationMessage {
                            Text(message)
                                .foregroundColor(message.contains("resent") ? .green : .red)
                                .font(.subheadline)
                                .padding(.top, 5)
                        }
                        
                        Button(action: {
                            Task {
                                isCheckingVerification = true
                                do {
                                    let isVerified = try await authViewModel.refreshEmailVerificationStatus(email: email, password: password)
                                    isCheckingVerification = false
                                    if isVerified {
                                        navigateToTabsView = true
                                    } else {
                                        verificationMessage = "Email not yet verified. Please check your email."
                                    }
                                } catch {
                                    isCheckingVerification = false
                                    verificationMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }) {
                            HStack {
                                if isCheckingVerification {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.2)
                                } else {
                                    Text("I’ve Verified My Email")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .disabled(isCheckingVerification)
                        
                        Button(action: {
                            Task {
                                do {
                                    try await authViewModel.resendEmailVerification(email: email, password: password)
                                    verificationMessage = "Verification email resent to \(email)."
                                } catch {
                                    verificationMessage = "Failed to resend: \(error.localizedDescription)"
                                }
                            }
                        }) {
                            Text("Resend Verification Email")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 10)
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .background(
                Group {
                    if #available(iOS 18.0, *) {
                        NavigationLink(destination: TabsView(selectedTab: $selectedTab)
                            .environmentObject(CartManager(isReadOnly: !authViewModel.isAuthenticated)),
                                       isActive: $navigateToTabsView) {
                            EmptyView()
                        }
                                       .hidden()
                    }
                }
            )
        }
    }
    
    private func handleSignUp() {
        guard isSignUpButtonEnabled else { return }
        
        Task {
            do {
                try await authViewModel.signUpAndLogin(email: email, password: password)
                showVerificationPrompt = true
            } catch {
                emailErrorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationViewModel())
}
