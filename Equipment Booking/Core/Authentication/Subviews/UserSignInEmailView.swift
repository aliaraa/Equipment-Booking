//
//  UserSignInEmailView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI

struct UserSignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @Binding var showPassword: Bool
    @State private var errorMessage: String? // For error display
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        VStack {
            // Email Field
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            // Password Field
            HStack {
                if showPassword {
                    TextField("Password...", text: $viewModel.password)
                } else {
                    SecureField("Password...", text: $viewModel.password)
                }
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)

            // Error Message Display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Sign In Button
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                    } catch {
                        // Handle Errors
                        if let error = error as NSError? {
                            if error.domain == "EmailNotRegistered" {
                                errorMessage = "Email not registered. Please sign up or try again."
                            } else if error.domain == "InvalidPassword" {
                                errorMessage = "Incorrect password. Please try again or reset it."
                            } else {
                                errorMessage = "An unknown error occurred."
                            }
                        }
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            // Options for Recovery
            HStack {
                Button("Sign Up") {
                    showSignUp = true
                }
                .foregroundColor(.blue)
                .padding()

                Button("Forgot Password") {
                    showForgotPassword = true
                }
                .foregroundColor(.blue)
                .padding()
            }
        }
        .padding()
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(email: $viewModel.email) // Pass the binding properly
        }

    }
}

struct UserSignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserSignInEmailView(showSignInView: .constant(false), showPassword: .constant(false))
        }
    }
}



