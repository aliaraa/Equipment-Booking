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
            VStack (spacing : 20){
                Text("Reset your password")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
                
//                TextField("Enter your email", text: $email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
                
               
                Text("Enter the email address registered to your account. You will receive a password reset link shortly!")
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                
                // Email Field (toDo Validate format!) //
                
                CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                
                Spacer()

                Button("Send Reset Link") {
                    // Add reset password logic here
                }
                .padding()
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)

//                Spacer()
            }
            .padding()
            .navigationTitle("")
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



#Preview {
    // Pass a mock binding for the `email` variable in preview
    ForgotPasswordView(email: .constant("test@testing.com"))
}

