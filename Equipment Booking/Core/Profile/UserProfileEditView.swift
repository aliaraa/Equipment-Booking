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
    @State private var isSaveButtonActive: Bool = false
    
    var body: some View {
        NavigationStack {
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
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
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
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Themed Text Field
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

//struct UserProfileEditView: View {
//    // MARK: - Properties
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    
//    // Editable user fields
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var phone: String = ""
//    @State private var address: String = ""
//    @State private var companyName: String = ""
//    @State private var profession: String = ""
//    
//    @State private var isSaveButtonActive: Bool = false
//    
//    // MARK: - Body
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 10) {
//                // Profile Header
//                VStack(spacing: 5) {
//                    AsyncImage(url: URL(string: viewModel.user?.photoUrl ?? "")) { image in
//                        image.resizable()
//                            .frame(width: 60, height: 60) // ✅ Smaller size for tighter layout
//                            .clipShape(Circle())
//                    } placeholder: {
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.yellow)
//                    }
//                    
//                    Text(viewModel.user?.email ?? "No Email")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//                .padding(.top, 10)
//                
//                // Editable Fields in a compact Form
//                Form {
//                    Section(header: Text("User Information").font(.subheadline)) { // ✅ Smaller header
//                        CustomProfileTextField(
//                            placeholder: "First Name",
//                            text: $firstName,
//                            isEditable: firstName.isEmpty, // ✅ Editable only if empty
//                            showClearButton: false, // ✅ No clear button for non-editable field
//                            onEditingChanged: checkForChanges
//                        )
//                        .disabled(!firstName.isEmpty) // ✅ Disable if pre-filled
//                        
//                        CustomProfileTextField(
//                            placeholder: "Last Name",
//                            text: $lastName,
//                            isEditable: lastName.isEmpty, // ✅ Editable only if empty
//                            showClearButton: false, // ✅ No clear button for non-editable field
//                            onEditingChanged: checkForChanges
//                        )
//                        .disabled(!lastName.isEmpty) // ✅ Disable if pre-filled
//                    }
//                    
//                    Section(header: Text("Additional Details").font(.subheadline)) {
//                        CustomProfileTextField(
//                            placeholder: "Phone Number",
//                            text: $phone,
//                            isEditable: true,
//                            showClearButton: true, // ✅ Add clear button
//                            onEditingChanged: checkForChanges
//                        )
//                        CustomProfileTextField(
//                            placeholder: "Mailing Address",
//                            text: $address,
//                            isEditable: true,
//                            showClearButton: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        CustomProfileTextField(
//                            placeholder: "Company Name",
//                            text: $companyName,
//                            isEditable: true,
//                            showClearButton: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        CustomProfileTextField(
//                            placeholder: "Profession",
//                            text: $profession,
//                            isEditable: true,
//                            showClearButton: true,
//                            onEditingChanged: checkForChanges
//                        )
//                    }
//                    
//                    Section {
//                        Button("Save Changes") {
//                            saveProfileChanges()
//                        }
//                        .font(.headline)
//                        .frame(height: 40) // ✅ Smaller button
//                        .frame(maxWidth: .infinity)
//                        .background(isSaveButtonActive ? Color.green : Color.gray)
//                        .cornerRadius(8) // ✅ Smaller radius
//                        .shadow(radius: 3)
//                        .foregroundColor(isSaveButtonActive ? .white : .black)
//                        .disabled(!isSaveButtonActive)
//                    }
//                }
//                .scrollContentBackground(.hidden) // ✅ Cleaner look
//                .onAppear { loadUserData() }
//            }
//            .navigationBarBackButtonHidden(true)
//            .navigationTitle("Edit Profile")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.headline)
//                            .foregroundColor(.yellow)
//                    }
//                }
//                // ✅ Home button removed
//            }
//        }
//    }
//    
//    // MARK: - Actions
//    private func checkForChanges() {
//        isSaveButtonActive = true
//    }
//    
//    private func loadUserData() {
//        Task {
//            await viewModel.loadCurrentUser()
//            if let user = viewModel.user {
//                firstName = user.firstName ?? ""
//                lastName = user.lastName ?? ""
//                phone = user.phone ?? ""
//                address = user.address ?? ""
//                companyName = user.companyName ?? ""
//                profession = user.profession ?? ""
//            }
//        }
//    }
//    
//    private func saveProfileChanges() {
//        Task {
//            do {
//                try await viewModel.updateUserProfile(
//                    firstName: firstName,
//                    lastName: lastName,
//                    phone: phone,
//                    address: address,
//                    companyName: companyName,
//                    profession: profession
//                )
//                isSaveButtonActive = false
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("Error updating profile: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    UserProfileEditView()
//}
//
//
