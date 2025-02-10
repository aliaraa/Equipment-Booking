//
//  ProfileSettingsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/13/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                    .autocapitalization(.words)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }

            Section(header: Text("Password")) {
                SecureField("New Password", text: $password)
            }

            Button(action: {
                // Save updated user information
            }) {
                Text("Save Changes")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Profile Settings")
    }
}

#Preview {
    ProfileSettingsView()
}
