//
//  UserProfileEditView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/20/25.
//

import SwiftUI
import Firebase
import FirebaseStorage
import PhotosUI

struct UserProfileEditView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
    @EnvironmentObject private var viewModel: UserProfileViewModel // Use environment/global object
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var companyName: String = ""
    @State private var profession: String = ""
    @State private var isSaveButtonActive: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var isLoadingImage: Bool = false // Loading state
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GradientBackground()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            if let profileImage = profileImage ?? (viewModel.profileImage.map { Image(uiImage: $0) }) {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                            } else if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Loading indicator
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Image(systemName: "person.crop.circle.fill")
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        Image(systemName: "person.crop.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            if isLoadingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 6)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .padding(6)
                                .background(Circle().fill(Color.blue.opacity(0.8)))
                                .offset(x: 35, y: 35)
                        )
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            isLoadingImage = true
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                profileImage = Image(uiImage: uiImage)
                                isSaveButtonActive = true
                            }
                            isLoadingImage = false
                        }
                    }
                    
                    Text(viewModel.user?.email ?? "No e-mail")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 20)
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal information")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        ProfileTextField(
                            icon: "person.fill",
                            placeholder: "First name",
                            text: $firstName,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                        ProfileTextField(
                            icon: "person.fill",
                            placeholder: "Last name",
                            text: $lastName,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("More information")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        ProfileTextField(
                            icon: "phone.fill",
                            placeholder: "Phone number",
                            text: $phone,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                        ProfileTextField(
                            icon: "house.fill",
                            placeholder: "Mailing address",
                            text: $address,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                        ProfileTextField(
                            icon: "building.2.fill",
                            placeholder: "Company name",
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
                    
                    Button(action: saveProfileChanges) {
                        Text("Save changes")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isSaveButtonActive ? Color.green.opacity(0.9) : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    .disabled(!isSaveButtonActive)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadUserData() }
        .onChange(of: viewModel.user?.photoUrl) { newPhotoUrl in
//            print("PhotoUrl updated in EditView: \(newPhotoUrl ?? "nil")")
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
                print("Loaded photoUrl in EditView: \(user.photoUrl ?? "nil")")
                // Use preloaded image from viewModel if available
                profileImage = viewModel.profileImage.map { Image(uiImage: $0) }
            }
        }
    }
 
    private func saveProfileChanges() {
        Task {
            do {
                // Ensure user ID is available
                guard let userId = viewModel.user?.userId else {
                    print("No user ID available")
                    return
                }
                
                // Start with the existing photo URL, if any
                var photoUrl = viewModel.user?.photoUrl
                
                // Handle image upload with resizing if a new photo is selected
                if let selectedPhoto = selectedPhoto,
                   let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    isLoadingImage = true // Show loading indicator
                    
                    // Resize the image to 200x200 pixels (adjust size as needed)
                    let resizedImage = uiImage.resized(to: CGSize(width: 200, height: 200))
                    if let resizedData = resizedImage?.jpegData(compressionQuality: 0.8) { // 80% quality ..reduce image size
                        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
                        
                        // Upload the resized image data
                        _ = try await storageRef.putDataAsync(resizedData, metadata: nil)
                        
                        // Get the download URL after upload
                        photoUrl = try await storageRef.downloadURL().absoluteString
                    } else {
                        print("Failed to resize or compress image")
                    }
                    
                    isLoadingImage = false // Hide loading indicator
                }
                
                // Update the user profile with new data and photo URL
                try await viewModel.updateUserProfile(
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    address: address,
                    companyName: companyName,
                    profession: profession,
                    photoUrl: photoUrl
                )
                
                // Reset UI state and dismiss the view
                isSaveButtonActive = false
                dismiss()
            } catch {
//                print("Error updating profile: \(error.localizedDescription)")
                isLoadingImage = false // Ensure loading indicator is hidden on error
            }
        }
    }
    

}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct ProfileTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let isEditable: Bool
    let onEditingChanged: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue.opacity(0.8))
                .font(.system(size: 18, weight: .medium))
            TextField(placeholder, text: $text, onEditingChanged: { _ in onEditingChanged() })
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.primary)
                .disabled(!isEditable)
            if !text.isEmpty && isEditable {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

#Preview {
    UserProfileEditView()
}
