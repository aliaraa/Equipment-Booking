//
//  ForgotPasswordView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/19/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Binding var email: String
    var onDismiss: (() -> Void)? // Callback for dismissing the view

    var body: some View {
        NavigationStack {
            VStack {
                Text("Forgot Password")
                    .font(.largeTitle)
                    .padding()

                TextField("Enter your email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)

                Button("Reset Password") {
                    // Add your reset password logic here
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss?() // Call dismiss callback
                    }
                }
            }
        }
    }
}


//struct ForgotPasswordView: View {
//    @Binding var email: String
//    @State private var errorMessage: String?
//    @State private var isSuccess = false
//
//    var body: some View {
//        VStack {
//            Text("Reset Your Password")
//                .font(.title2)
//                .padding()
//
//            TextField("Email...", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            Button("Send Reset Link") {
//                Task {
//                    do {
//                        try await AuthenticationManager.shared.resetPassword(email: email)
//                        isSuccess = true
//                    } catch {
//                        errorMessage = "Failed to send reset link. Please try again."
//                    }
//                }
//            }
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//
//            if isSuccess {
//                Text("Reset link sent! Check your email.")
//                    .foregroundColor(.green)
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    // Fix the initializer to explicitly take a `Binding<String>`
//    public init(email: Binding<String>) {
//        self._email = email
//    }
//}

#Preview {
    // Pass a mock binding for the `email` variable in preview
    ForgotPasswordView(email: .constant("test@testing.com"))
}

