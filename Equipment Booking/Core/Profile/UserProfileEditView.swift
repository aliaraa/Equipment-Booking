//
//  UserProfileEditView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/20/25.
//

import SwiftUI
import Firebase

struct UserProfileEditView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var companyName: String = ""
    @State private var profession: String = ""
    
    @State private var isEditing: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                // User Information Section
                Section(header: Text("User Information")) {
                    TextField("First Name", text: $firstName)
                        .disabled(!isEditing)
                    
                    TextField("Last Name", text: $lastName)
                        .disabled(!isEditing)
                    
                    Text(viewModel.user?.email ?? "No Email") // Email (non-editable)
                        .foregroundColor(.gray)
                }
                
                // Additional Attributes
                Section(header: Text("Additional Details")) {
                    TextField("Phone Number", text: $phone)
                        .disabled(!isEditing)
                    
                    TextField("Mailing Address", text: $address)
                        .disabled(!isEditing)
                    
                    TextField("Company Name", text: $companyName)
                        .disabled(!isEditing)
                    
                    TextField("Profession", text: $profession)
                        .disabled(!isEditing)
                }
                
                // Edit & Save Button
                Section {
                    if isEditing {
                        Button("Save Changes") {
                            saveProfileChanges()
                        }
                        .foregroundColor(.green)
                    } else {
                        Button("Edit Profile") {
                            isEditing.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                loadUserData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Load user data from Firestore
    private func loadUserData() {
        Task {
            await viewModel.loadCurrentUser()
            if let user = viewModel.user {
                firstName = user.firstName ?? ""
                lastName = user.lastName ?? ""
                phone = user.phone ?? ""
                address = user.address ?? ""
                companyName = user.companyName ?? ""
                profession = user.profession ?? ""
            }
        }
    }
    
    // Save user changes to Firestore
    private func saveProfileChanges() {
        Task {
            do {
                try await viewModel.updateUserProfile(
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    address: address,
                    companyName: companyName,
                    profession: profession
                )
                isEditing = false
            } catch {
                errorMessage = "Failed to update profile: \(error.localizedDescription)"
            }
        }
    }
}

