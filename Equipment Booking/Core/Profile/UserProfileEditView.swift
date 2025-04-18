//
//  UserProfileEditView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/20/25.
//

import SwiftUI
import PhotosUI
import UIKit
import FirebaseAuth
import FirebaseStorage
import Photos

struct UserProfileEditView: View {
    @EnvironmentObject private var viewModel: UserProfileViewModel
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
    @State private var isLoadingImage: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GradientBackground()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                            } else if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
                                Async_Image(url: url)
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
                    // CHANGE: Request permission early and log status
                    .onAppear {
                        Task {
                            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                            print("Initial photo permission status: \(status.rawValue) (\(status))")
                            if status == .notDetermined {
                                let newStatus = await PHPhotoLibrary.requestAuthorizationAsync(for: .readWrite)
                                print("Requested permission, new status: \(newStatus.rawValue) (\(newStatus))")
                            } else if status == .denied || status == .restricted {
                                print("Photo access denied/restricted, prompting user")
                                errorMessage = "Please enable photo access in Settings > Privacy > Photos."
                                showErrorAlert = true
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            isLoadingImage = true
                            do {
                                // CHANGE: Verify permission before loading
                                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                                print("Photo permission on selection: \(status.rawValue) (\(status))")
                                if status != .authorized && status != .limited {
                                    throw NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Photo access not granted"])
                                }
                                if let data = try await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                    isSaveButtonActive = true
                                    print("Photo selected, save button enabled")
                                } else {
                                    profileImage = nil
                                    selectedPhoto = nil
                                    print("No photo data loaded")
                                }
                            } catch {
                                print("Photo picker error: \(error)")
                                errorMessage = error.localizedDescription.contains("Photo") ?
                                    "Please enable photo access in Settings > Privacy > Photos." :
                                    "Failed to load photo. Please try again."
                                showErrorAlert = true
                                selectedPhoto = nil
                            }
                            isLoadingImage = false
                        }
                    }
                    
                    Text(viewModel.user?.email ?? "No email")
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
                    .disabled(!isSaveButtonActive || isLoadingImage)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.asyncOnce(token: "loadUserData") {
                loadUserData()
            }
        }
        .alert("Profile Save Error", isPresented: $showErrorAlert, actions: {
            Button("OK") {
                if errorMessage?.contains("Photo") == true, let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                showErrorAlert = false
            }
        }, message: {
            Text(errorMessage ?? "Failed to save profile changes")
        })
    }
    
    private func checkForChanges() {
        isSaveButtonActive = firstName != (viewModel.user?.firstName ?? "") ||
                            lastName != (viewModel.user?.lastName ?? "") ||
                            phone != (viewModel.user?.phone ?? "") ||
                            address != (viewModel.user?.address ?? "") ||
                            companyName != (viewModel.user?.companyName ?? "") ||
                            profession != (viewModel.user?.profession ?? "") ||
                            selectedPhoto != nil
        print("checkForChanges: isSaveButtonActive=\(isSaveButtonActive)")
    }
    
    private func loadUserData() {
        guard firstName.isEmpty else { return }
        Task {
            print("Loading user data in EditView")
            await viewModel.loadCurrentUser(forceServer: true)
            if let user = viewModel.user {
                firstName = user.firstName ?? ""
                lastName = user.lastName ?? ""
                phone = user.phone ?? ""
                address = user.address ?? ""
                companyName = user.companyName ?? ""
                profession = user.profession ?? ""
                print("EditView loaded: firstName=\(user.firstName ?? "nil"), img_url=\(user.photoUrl ?? "nil")")
            } else {
                print("No user data loaded")
            }
        }
    }
    
    private func saveProfileChanges() {
        Task {
            print("Starting saveProfileChanges")
            var saveError: Error?
            defer {
                isSaveButtonActive = false
                selectedPhoto = nil
                isLoadingImage = false
                profileImage = nil
                if let error = saveError {
                    errorMessage = error.localizedDescription.contains("permission") ?
                        "Failed to upload image. Please sign out and back in." :
                        error.localizedDescription
                    print("Save error: \(errorMessage ?? "nil")")
                    showErrorAlert = true
                } else {
                    print("Save successful, dismissing")
                    dismiss()
                }
            }
            
            do {
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("Save failed: No authenticated user")
                    saveError = NSError(domain: "UserProfileEdit", code: -5, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
                    return
                }
                print("Authenticated user UID: \(userId)")
                
                // CHANGE: Verify permission before any photo access
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                print("Photo permission status before upload: \(status.rawValue) (\(status))")
                if status != .authorized && status != .limited {
                    print("Save failed: Photo library access denied")
                    saveError = NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Please enable photo access in Settings > Privacy > Photos."])
                    return
                }
                
                var photoUrl: String? = viewModel.user?.photoUrl
                if let selectedPhoto = selectedPhoto {
                    isLoadingImage = true
                    print("Loading photo data from PhotosPicker")
                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                        print("Save failed: No photo data")
                        saveError = NSError(domain: "UserProfileEdit", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to load photo"])
                        return
                    }
                    guard let uiImage = UIImage(data: data) else {
                        print("Save failed: Invalid image data")
                        saveError = NSError(domain: "UserProfileEdit", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                        return
                    }
                    let resizedImage = uiImage.resized(to: CGSize(width: 200, height: 200))
                    guard let resizedData = resizedImage?.jpegData(compressionQuality: 0.8) else {
                        print("Save failed: Failed to resize image")
                        saveError = NSError(domain: "UserProfileEdit", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
                        return
                    }
                    let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
                    print("Storage path: \(storageRef.fullPath)")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    print("Attempting Storage upload to: \(storageRef.fullPath)")
                    _ = try await storageRef.putDataAsync(resizedData, metadata: metadata)
                    photoUrl = try await storageRef.downloadURL().absoluteString
                    print("Uploaded new photoUrl: \(photoUrl ?? "nil")")
                    if let oldUrl = viewModel.user?.photoUrl, oldUrl != photoUrl {
                        ProfileImageCache.shared.removeImage(forKey: oldUrl)
                    }
                }
                
                print("Updating Firestore: firstName=\(firstName), img_url=\(photoUrl ?? "nil")")
                try await viewModel.updateUserProfile(
                    firstName: firstName.isEmpty ? nil : firstName,
                    lastName: lastName.isEmpty ? nil : lastName,
                    phone: phone.isEmpty ? nil : phone,
                    address: address.isEmpty ? nil : address,
                    companyName: companyName.isEmpty ? nil : companyName,
                    profession: profession.isEmpty ? nil : profession,
                    photoUrl: photoUrl
                )
                print("Firestore update complete")
            } catch {
                print("Profile update failed: \(error)")
                saveError = error
            }
        }
    }
}

extension PHPhotoLibrary {
    static func requestAuthorizationAsync(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            requestAuthorization(for: accessLevel) { status in
                continuation.resume(returning: status)
            }
        }
    }
}


//struct UserProfileEditView: View {
//    @EnvironmentObject private var viewModel: UserProfileViewModel
//    @Environment(\.dismiss) var dismiss
//    
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var phone: String = ""
//    @State private var address: String = ""
//    @State private var companyName: String = ""
//    @State private var profession: String = ""
//    @State private var isSaveButtonActive: Bool = false
//    @State private var selectedPhoto: PhotosPickerItem? = nil
//    @State private var profileImage: Image? = nil
//    @State private var isLoadingImage: Bool = false
//    @State private var showErrorAlert: Bool = false
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                GradientBackground()
//                    .frame(height: 200)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                
//                VStack(spacing: 12) {
//                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
//                        ZStack {
//                            if let profileImage = profileImage {
//                                profileImage
//                                    .resizable()
//                                    .scaledToFill()
//                            } else if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
//                                Async_Image(url: url)
//                            } else {
//                                Image(systemName: "person.crop.circle.fill")
//                                    .foregroundColor(.gray)
//                            }
//                            if isLoadingImage {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle())
//                                    .scaleEffect(1.5)
//                            }
//                        }
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
//                        .shadow(radius: 6)
//                        .overlay(
//                            Image(systemName: "camera.fill")
//                                .foregroundColor(.white)
//                                .font(.system(size: 16))
//                                .padding(6)
//                                .background(Circle().fill(Color.blue.opacity(0.8)))
//                                .offset(x: 35, y: 35)
//                        )
//                    }
//                    // CHANGE: Simplified onChange to update isSaveButtonActive directly
//                    .onChange(of: selectedPhoto) { newItem in
//                        Task {
//                            isLoadingImage = true
//                            do {
//                                if let data = try await newItem?.loadTransferable(type: Data.self),
//                                   let uiImage = UIImage(data: data) {
//                                    profileImage = Image(uiImage: uiImage)
//                                    isSaveButtonActive = true // Enable save button
//                                    print("Photo selected, save button enabled")
//                                } else {
//                                    profileImage = nil
//                                    print("No photo data loaded")
//                                }
//                            } catch {
//                                print("Photo picker error: \(error)")
//                                errorMessage = "Failed to load photo"
//                                showErrorAlert = true
//                            }
//                            isLoadingImage = false
//                        }
//                    }
//                    
//                    Text(viewModel.user?.email ?? "No email")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.9))
//                }
//                .padding(.top, 20)
//            }
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Personal information")
//                            .font(.system(size: 18, weight: .bold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        ProfileTextField(
//                            icon: "person.fill",
//                            placeholder: "First name",
//                            text: $firstName,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        ProfileTextField(
//                            icon: "person.fill",
//                            placeholder: "Last name",
//                            text: $lastName,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("More information")
//                            .font(.system(size: 18, weight: .bold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        ProfileTextField(
//                            icon: "phone.fill",
//                            placeholder: "Phone number",
//                            text: $phone,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        ProfileTextField(
//                            icon: "house.fill",
//                            placeholder: "Mailing address",
//                            text: $address,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        ProfileTextField(
//                            icon: "building.2.fill",
//                            placeholder: "Company name",
//                            text: $companyName,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                        ProfileTextField(
//                            icon: "briefcase.fill",
//                            placeholder: "Profession",
//                            text: $profession,
//                            isEditable: true,
//                            onEditingChanged: checkForChanges
//                        )
//                    }
//                    
//                    Button(action: saveProfileChanges) {
//                        Text("Save changes")
//                            .font(.system(size: 16, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 14)
//                            .background(isSaveButtonActive ? Color.green.opacity(0.9) : Color.gray.opacity(0.5))
//                            .cornerRadius(12)
//                            .shadow(radius: 4)
//                    }
//                    .disabled(!isSaveButtonActive || isLoadingImage)
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 20)
//            }
//            .background(Color(.systemBackground))
//        }
//        .navigationTitle("Edit profile")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            DispatchQueue.asyncOnce(token: "loadUserData") {
//                loadUserData()
//            }
//        }
//        .alert("Profile Save Error", isPresented: $showErrorAlert, actions: {
//            Button("OK") {
//                if errorMessage?.contains("Photo") == true, let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(settingsUrl)
//                }
//                showErrorAlert = false
//            }
//        }, message: {
//            Text(errorMessage ?? "Failed to save profile changes")
//        })
//    }
//    
//    private func checkForChanges() {
//        isSaveButtonActive = firstName != (viewModel.user?.firstName ?? "") ||
//                            lastName != (viewModel.user?.lastName ?? "") ||
//                            phone != (viewModel.user?.phone ?? "") ||
//                            address != (viewModel.user?.address ?? "") ||
//                            companyName != (viewModel.user?.companyName ?? "") ||
//                            profession != (viewModel.user?.profession ?? "") ||
//                            selectedPhoto != nil
//        print("checkForChanges: isSaveButtonActive=\(isSaveButtonActive)")
//    }
//    
//    private func loadUserData() {
//        guard firstName.isEmpty else { return }
//        Task {
//            print("Loading user data in EditView")
//            await viewModel.loadCurrentUser(forceServer: true)
//            if let user = viewModel.user {
//                firstName = user.firstName ?? ""
//                lastName = user.lastName ?? ""
//                phone = user.phone ?? ""
//                address = user.address ?? ""
//                companyName = user.companyName ?? ""
//                profession = user.profession ?? ""
//                print("EditView loaded: firstName=\(user.firstName ?? "nil"), img_url=\(user.photoUrl ?? "nil")")
//            } else {
//                print("No user data loaded")
//            }
//        }
//    }
//    
//    private func saveProfileChanges() {
//        Task {
//            print("Starting saveProfileChanges")
//            var saveError: Error?
//            defer {
//                isSaveButtonActive = false
//                selectedPhoto = nil
//                isLoadingImage = false
//                profileImage = nil
//                if let error = saveError {
//                    errorMessage = error.localizedDescription.contains("Photo") ?
//                        "Please enable photo access in Settings > Privacy > Photos." :
//                        error.localizedDescription.contains("permission") ?
//                        "Failed to upload image. Please sign out and back in." :
//                        error.localizedDescription
//                    print("Save error: \(errorMessage ?? "nil")")
//                    showErrorAlert = true
//                } else {
//                    print("Save successful, dismissing")
//                    dismiss()
//                }
//            }
//            
//            do {
//                guard let userId = Auth.auth().currentUser?.uid else {
//                    print("Save failed: No authenticated user")
//                    saveError = NSError(domain: "UserProfileEdit", code: -5, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
//                    return
//                }
//                print("Authenticated user UID: \(userId)")
//                
//                var photoUrl: String? = viewModel.user?.photoUrl
//                if let selectedPhoto = selectedPhoto {
//                    isLoadingImage = true
//                    // CHANGE: Prompt for photo permissions
//                    let status = await PHPhotoLibrary.requestAuthorizationAsync(for: .readWrite)
//                    if status != .authorized && status != .limited {
//                        print("Save failed: Photo library access denied")
//                        saveError = NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])
//                        return
//                    }
//                    print("Photo library access granted")
//                    
//                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
//                        print("Save failed: No photo data")
//                        saveError = NSError(domain: "UserProfileEdit", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to load photo"])
//                        return
//                    }
//                    guard let uiImage = UIImage(data: data) else {
//                        print("Save failed: Invalid image data")
//                        saveError = NSError(domain: "UserProfileEdit", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
//                        return
//                    }
//                    let resizedImage = uiImage.resized(to: CGSize(width: 200, height: 200))
//                    guard let resizedData = resizedImage?.jpegData(compressionQuality: 0.8) else {
//                        print("Save failed: Failed to resize image")
//                        saveError = NSError(domain: "UserProfileEdit", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
//                        return
//                    }
//                    let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
//                    print("Storage path: \(storageRef.fullPath)")
//                    let metadata = StorageMetadata()
//                    metadata.contentType = "image/jpeg"
//                    // CHANGE: Removed retry loop, simplified upload
//                    _ = try await storageRef.putDataAsync(resizedData, metadata: metadata)
//                    photoUrl = try await storageRef.downloadURL().absoluteString
//                    print("Uploaded new photoUrl: \(photoUrl ?? "nil")")
//                    if let oldUrl = viewModel.user?.photoUrl, oldUrl != photoUrl {
//                        ProfileImageCache.shared.removeImage(forKey: oldUrl)
//                    }
//                }
//                
//                print("Updating Firestore: firstName=\(firstName), img_url=\(photoUrl ?? "nil")")
//                try await viewModel.updateUserProfile(
//                    firstName: firstName.isEmpty ? nil : firstName,
//                    lastName: lastName.isEmpty ? nil : lastName,
//                    phone: phone.isEmpty ? nil : phone,
//                    address: address.isEmpty ? nil : address,
//                    companyName: companyName.isEmpty ? nil : companyName,
//                    profession: profession.isEmpty ? nil : profession,
//                    photoUrl: photoUrl
//                )
//                print("Firestore update complete")
//            } catch {
//                print("Profile update failed: \(error)")
//                saveError = error
//            }
//        }
//    }
//}
//
//// CHANGE: Helper to prompt for photo permissions
//extension PHPhotoLibrary {
//    static func requestAuthorizationAsync(for accessLevel: PHAccessLevel) async -> PHAuthorizationStatus {
//        await withCheckedContinuation { continuation in
//            requestAuthorization(for: accessLevel) { status in
//                continuation.resume(returning: status)
//            }
//        }
//    }
//}

struct Async_Image: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.gray)
            @unknown default:
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.gray)
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

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension DispatchQueue {
    static var onceTokens: [String] = []
    static func asyncOnce(token: String = #function, execute: @escaping () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        guard !onceTokens.contains(token) else { return }
        onceTokens.append(token)
        DispatchQueue.main.async { execute() }
    }
}

#Preview {
    UserProfileEditView()
        .environmentObject(UserProfileViewModel())
}

