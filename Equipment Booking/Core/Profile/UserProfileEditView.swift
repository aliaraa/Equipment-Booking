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

    // Editable user fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var companyName: String = ""
    @State private var profession: String = ""

    @State private var isFirstNameEditable: Bool = false
    @State private var isLastNameEditable: Bool = false
    @State private var isSaveButtonActive: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Profile Header
                VStack(spacing: 5) {
                    AsyncImage(url: URL(string: viewModel.user?.photoUrl ?? "")) { image in
                        image.resizable()
                            .frame(width: 80, height: 80) // ✅ Reduced size
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80) // ✅ Reduced size
                            .foregroundColor(.yellow)
                    }
                    
                    Text(viewModel.user?.email ?? "No Email")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                // Editable Fields
                Form {
                    Section(header: Text("User Information")) {
                        CustomProfileTextField(
                            placeholder: "First Name",
                            text: $firstName,
                            isEditable: isFirstNameEditable,
                            onEditingChanged: checkForChanges
                        )
                        .onAppear { isFirstNameEditable = firstName.isEmpty }

                        CustomProfileTextField(
                            placeholder: "Last Name",
                            text: $lastName,
                            isEditable: isLastNameEditable,
                            onEditingChanged: checkForChanges
                        )
                        .onAppear { isLastNameEditable = lastName.isEmpty }
                    }

                    Section(header: Text("Additional Details")) {
                        CustomProfileTextField(placeholder: "Phone Number", text: $phone, isEditable: true, onEditingChanged: checkForChanges)
                        CustomProfileTextField(placeholder: "Mailing Address", text: $address, isEditable: true, onEditingChanged: checkForChanges)
                        CustomProfileTextField(placeholder: "Company Name", text: $companyName, isEditable: true, onEditingChanged: checkForChanges)
                        CustomProfileTextField(placeholder: "Profession", text: $profession, isEditable: true, onEditingChanged: checkForChanges)
                    }

                    Section {
                        Button("Save Changes") {
                            saveProfileChanges()
                        }

                        .font(.headline)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(isSaveButtonActive ? Color.green : Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(isSaveButtonActive ? .white : .black) // ✅ Better contrast
                        .disabled(!isSaveButtonActive) // ✅ Starts disabled
                    }
                }
                .onAppear { loadUserData() }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ✅ Back Button (Chevron)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }

                // ✅ Home Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: navigateToHome) {
                        Image(systemName: "house.fill")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }

    // ✅ Track changes to enable Save button
    private func checkForChanges() {
        isSaveButtonActive = true
    }

    // ✅ Load user data
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

    // ✅ Save user changes
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
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
            }
        }
    }

    // ✅ Navigate to Home (TabsView)
    private func navigateToHome() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            if #available(iOS 18.0, *) {
                window.rootViewController = UIHostingController(rootView: TabsView())
            } else {
                // Fallback on earlier versions
            }
            window.makeKeyAndVisible()
        }
    }
}



#Preview {
    UserProfileEditView()
}
