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
    @Environment(\.dismiss) var dismiss // For dismissing back to UserProfileView
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var companyName: String = ""
    @State private var profession: String = ""
    @State private var isSaveButtonActive: Bool = false
    
    var body: some View {
        // Remove NavigationStack; rely on parent stack from UserProfileView
        VStack(spacing: 10) {
            VStack(spacing: 5) {
                AsyncImage(url: URL(string: viewModel.user?.photoUrl ?? "")) { image in
                    image.resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.yellow)
                }
                
                Text(viewModel.user?.email ?? "No Email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            
            Form {
                Section(header: Text("User Information").font(.subheadline)) {
                    ProfileTextField(
                        icon: "person.fill",
                        placeholder: "First Name",
                        text: $firstName,
                        isEditable: firstName.isEmpty,
                        onEditingChanged: checkForChanges
                    )
                    .disabled(!firstName.isEmpty)
                    
                    ProfileTextField(
                        icon: "person.fill",
                        placeholder: "Last Name",
                        text: $lastName,
                        isEditable: lastName.isEmpty,
                        onEditingChanged: checkForChanges
                    )
                    .disabled(!lastName.isEmpty)
                }
                
                Section(header: Text("Additional Details").font(.subheadline)) {
                    ProfileTextField(
                        icon: "phone.fill",
                        placeholder: "Phone Number",
                        text: $phone,
                        isEditable: true,
                        onEditingChanged: checkForChanges
                    )
                    ProfileTextField(
                        icon: "house.fill",
                        placeholder: "Mailing Address",
                        text: $address,
                        isEditable: true,
                        onEditingChanged: checkForChanges
                    )
                    ProfileTextField(
                        icon: "building.2.fill",
                        placeholder: "Company Name",
                        text: $companyName,
                        isEditable: true,
                        onEditingChanged: checkForChanges
                    )
                    ProfileTextField(
                        icon: "briefcase.fill",
                        placeholder: "Profession",
                        text: $profession,
                        isEditable: true,
                        onEditingChanged: checkForChanges
                    )
                }
                
                Section {
                    Button("Save Changes") {
                        saveProfileChanges()
                    }
                    .font(.headline)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(isSaveButtonActive ? Color.green : Color.gray)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .foregroundColor(isSaveButtonActive ? .white : .black)
                    .disabled(!isSaveButtonActive)
                }
            }
            .scrollContentBackground(.hidden)
            .onAppear { loadUserData() }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func checkForChanges() {
        isSaveButtonActive = true
    }
    
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
                isSaveButtonActive = false
                dismiss() // Return to UserProfileView
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
            }
        }
    }
}

struct ProfileTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isEditable: Bool
    let onEditingChanged: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.headline)
            TextField(placeholder, text: $text, onEditingChanged: { _ in onEditingChanged() })
                .disabled(!isEditable)
                .foregroundColor(.black)
                .font(.headline)
            Spacer()
            if !text.isEmpty && isEditable {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
        .shadow(radius: 2)
    }
}

#Preview {
    UserProfileEditView()
}
