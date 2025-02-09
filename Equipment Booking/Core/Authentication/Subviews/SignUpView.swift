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
    @State private var showSuccessAlert: Bool = false
    @State private var navigateToEquipmentListing: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Focus tracking
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }

    // Computed property to enable/disable Sign Up button
    private var isSignUpButtonEnabled: Bool {
        return emailErrorMessage == nil &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               confirmPasswordErrorMessage == nil
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss() // Ensure it goes back
        }) {
            HStack {
                Image(systemName: "chevron.left")
//                Text("Back")
            }
            .foregroundColor(Color(UIColor.darkGray))
        }
    }


    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Text("Create Your Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)

                // Email Field (Validate when moving focus away)
                CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                    .focused($focusedField, equals: .email)
                //  Validate when user leaves the field
                    .onChange(of: focusedField) { newFocus in
                        if newFocus != .email {
                            emailErrorMessage = ValidationHelper.validateEmail(email)
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
                CustomSecureField(icon: "lock", placeholder: "Password", text: $password, isSecure: !showPassword, toggle: { showPassword.toggle() })
                    .focused($focusedField, equals: .password)

                // Confirm Password Field (Validate in real-time)
                CustomSecureField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: !showConfirmPassword, toggle: { showConfirmPassword.toggle() })
                    .focused($focusedField, equals: .confirmPassword)
                    .onChange(of: confirmPassword) {
                        _ in confirmPasswordErrorMessage = ValidationHelper.validateConfirmPassword(password: password, confirmPassword: confirmPassword) }
                
                // Validate only in Confirm Password field

                if let confirmPasswordErrorMessage = confirmPasswordErrorMessage {
                    Text(confirmPasswordErrorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // Sign Up Button
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

                Spacer()
            }
            .padding()

            .navigationBarBackButtonHidden(true) // Hide default back button
            .navigationBarItems(leading: backButton)


            .alert("Registration Successful!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    navigateToEquipmentListing = true
                }
            } message: {
                Text("You have successfully signed up and are now logged in.")
            }
            
            NavigationLink(destination: EquipmentListingView(), isActive: $navigateToEquipmentListing) {
                EmptyView()
            }
            .hidden()
            
            
        }

    }
    

    // Sign-Up Logic
    private func handleSignUp() {
        guard isSignUpButtonEnabled else { return }

        Task {
            do {
                try await authViewModel.signUpAndLogin(email: email, password: password)
                showSuccessAlert = true
            } catch {
                emailErrorMessage = error.localizedDescription
            }
        }
    }
}


#Preview {
    SignUpView()
}



