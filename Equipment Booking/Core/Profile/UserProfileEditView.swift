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
import FirebaseFirestore

struct Async_Image: View {
    let url: URL
    let photoUrl: String
    
    var body: some View {
        if let cachedImage = ProfileImageCache.shared.getImage(forKey: photoUrl) {
            Image(uiImage: cachedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(radius: 6)
                .onAppear { print("Using cached image: \(photoUrl)") }
        } else {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .onAppear { print("AsyncImage loading: \(photoUrl)") }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 6)
                        .onAppear { print("AsyncImage loaded: \(photoUrl)") }
                case .failure(let error):
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .onAppear { print("AsyncImage failed: \(photoUrl), error: \(error)") }
                @unknown default:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct UserProfileEditView: View {
    @EnvironmentObject private var viewModel: UserProfileViewModel
    @EnvironmentObject private var cartManager: CartManager
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
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
    @State private var errorMessage: String? = nil
    @State private var canAccessPhotos: Bool = false
    @State private var hasLoadedData: Bool = false
    
    var body: some View {
        Group {
            if viewModel != nil && cartManager != nil && authViewModel != nil {
                VStack(spacing: 0) {
                    ZStack {
                        GradientBackground()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(spacing: 12) {
                            if canAccessPhotos {
                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    ZStack {
                                        if let profileImage = profileImage {
                                            profileImage
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                                .shadow(radius: 6)
                                        } else if let photoUrl = viewModel.user?.photoUrl, !photoUrl.isEmpty, let url = URL(string: photoUrl) {
                                            Async_Image(url: url, photoUrl: photoUrl)
                                        } else {
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.gray)
                                                .onAppear { print("No photoUrl, using placeholder") }
                                        }
                                        if isLoadingImage {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                                .scaleEffect(1.5)
                                        }
                                    }
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                            .padding(6)
                                            .background(Circle().fill(Color.blue.opacity(0.8)))
                                            .offset(x: 35, y: 35)
                                    )
                                }
                                .onAppear { print("PhotosPicker initialized") }
                                .onChange(of: selectedPhoto) { newItem in
                                    Task {
                                        isLoadingImage = true
                                        defer { isLoadingImage = false }
                                        do {
                                            guard let item = newItem else {
                                                profileImage = nil
                                                isSaveButtonActive = checkForChanges()
                                                print("Cleared selected photo")
                                                return
                                            }
                                            let status = await requestPhotoLibraryAccess()
                                            switch status {
                                            case .authorized, .limited:
                                                print("Photo access granted: \(status.rawValue) (\(status.description))")
                                            case .denied:
                                                throw NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])
                                            case .restricted:
                                                throw NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Photo library access restricted by system settings"])
                                            case .notDetermined:
                                                print("Unexpected notDetermined status after request")
                                                throw NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Photo library access not determined"])
                                            @unknown default:
                                                throw NSError(domain: "UserProfileEdit", code: -7, userInfo: [NSLocalizedDescriptionKey: "Unknown photo library access status"])
                                            }
                                            guard let data = try await item.loadTransferable(type: Data.self) else {
                                                throw NSError(domain: "UserProfileEdit", code: -8, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
                                            }
                                            print("Loaded image data: \(data.count) bytes")
                                            guard let uiImage = UIImage(data: data) else {
                                                throw NSError(domain: "UserProfileEdit", code: -9, userInfo: [NSLocalizedDescriptionKey: "Invalid image format"])
                                            }
                                            guard uiImage.size.width > 0, uiImage.size.height > 0 else {
                                                throw NSError(domain: "UserProfileEdit", code: -10, userInfo: [NSLocalizedDescriptionKey: "Image has invalid dimensions"])
                                            }
                                            guard let imageType = data.imageType, ["jpeg", "png"].contains(imageType) else {
                                                throw NSError(domain: "UserProfileEdit", code: -11, userInfo: [NSLocalizedDescriptionKey: "Unsupported image type: \(data.imageType ?? "unknown")"])
                                            }
                                            profileImage = Image(uiImage: uiImage)
                                            isSaveButtonActive = true
                                            print("Valid photo selected: type=\(imageType), size=\(uiImage.size)")
                                        } catch {
                                            print("Photo selection error: \(error)")
                                            errorMessage = {
                                                if error.localizedDescription.contains("access denied") {
                                                    return "Please enable photo access in Settings > Privacy > Photos."
                                                } else if error.localizedDescription.contains("restricted") {
                                                    return "Photo access is restricted by system settings."
                                                } else {
                                                    return "Failed to load photo: \(error.localizedDescription)"
                                                }
                                            }()
                                            showErrorAlert = true
                                            profileImage = nil
                                            selectedPhoto = nil
                                            isSaveButtonActive = checkForChanges()
                                        }
                                    }
                                }
                            } else {
                                ZStack {
                                    if let photoUrl = viewModel.user?.photoUrl, !photoUrl.isEmpty, let url = URL(string: photoUrl) {
                                        Async_Image(url: url, photoUrl: photoUrl)
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                            .onAppear { print("No photoUrl, using placeholder (no photo access)") }
                                    }
                                    if isLoadingImage {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(1.5)
                                    }
                                }
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                        .padding(6)
                                        .background(Circle().fill(Color.gray.opacity(0.8)))
                                        .offset(x: 35, y: 35)
                                        .onTapGesture {
                                            errorMessage = "Please enable photo access in Settings > Privacy > Photos to change your profile picture."
                                            showErrorAlert = true
                                        }
                                )
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
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
                                )
                                ProfileTextField(
                                    icon: "person.fill",
                                    placeholder: "Last name",
                                    text: $lastName,
                                    isEditable: true,
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
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
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
                                )
                                ProfileTextField(
                                    icon: "house.fill",
                                    placeholder: "Mailing address",
                                    text: $address,
                                    isEditable: true,
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
                                )
                                ProfileTextField(
                                    icon: "building.2.fill",
                                    placeholder: "Company name",
                                    text: $companyName,
                                    isEditable: true,
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
                                )
                                ProfileTextField(
                                    icon: "briefcase.fill",
                                    placeholder: "Profession",
                                    text: $profession,
                                    isEditable: true,
                                    onEditingChanged: { isSaveButtonActive = checkForChanges() }
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
            } else {
                Text("Error: Unable to load profile editor")
                    .foregroundColor(.red)
                    .font(.title)
                    .onAppear {
                        print("UserProfileEditView: Missing environment objects")
                    }
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("UserProfileEditView onAppear: viewModel=\(viewModel != nil), cartManager=\(cartManager != nil), authViewModel=\(authViewModel != nil)")
            if !hasLoadedData {
                hasLoadedData = true
                loadUserData()
                Task {
                    let status = await requestPhotoLibraryAccess()
                    canAccessPhotos = status == .authorized || status == .limited || status == .notDetermined
                    print("Initial photo access check: canAccessPhotos=\(canAccessPhotos), status=\(status.description)")
                }
            }
        }
        .alert("Profile Save Error", isPresented: $showErrorAlert, actions: {
            Button("OK") {
                if errorMessage?.contains("photo access") == true || errorMessage?.contains("restricted") == true, let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                showErrorAlert = false
            }
        }, message: {
            Text(errorMessage ?? "Failed to save profile changes")
        })
    }
    
    private func requestPhotoLibraryAccess() async -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        print("Photo library status: \(status.rawValue) (\(status.description))")
        if status == .notDetermined {
            let newStatus = await PHPhotoLibrary.requestAuthorizationAsync(for: .readWrite)
            print("Requested photo access, new status: \(newStatus.rawValue) (\(newStatus.description))")
            return newStatus
        }
        return status
    }
    
    private func checkForChanges() -> Bool {
        let hasChanges = firstName != (viewModel.user?.firstName ?? "") ||
                         lastName != (viewModel.user?.lastName ?? "") ||
                         phone != (viewModel.user?.phone ?? "") ||
                         address != (viewModel.user?.address ?? "") ||
                         companyName != (viewModel.user?.companyName ?? "") ||
                         profession != (viewModel.user?.profession ?? "") ||
                         selectedPhoto != nil
        print("checkForChanges: hasChanges=\(hasChanges)")
        return hasChanges
    }
    
    private func loadUserData() {
        guard firstName.isEmpty else { return }
        Task {
            print("Loading user data in EditView")
            do {
                try await viewModel.loadCurrentUser(forceServer: true)
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
                    errorMessage = "Failed to load user data"
                    showErrorAlert = true
                }
            } catch {
                print("Failed to load user data: \(error)")
                errorMessage = "Error loading profile: \(error.localizedDescription)"
                showErrorAlert = true
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
                    errorMessage = {
                        if error.localizedDescription.contains("access denied") {
                            return "Please enable photo access in Settings > Privacy > Photos."
                        } else if error.localizedDescription.contains("restricted") {
                            return "Photo access is restricted by system settings."
                        } else if error.localizedDescription.contains("Permission denied") {
                            return "Failed to upload image. Please check Firebase Storage permissions or try again."
                        } else if error.localizedDescription.contains("Not authenticated") {
                            return "Please log in again to save profile changes."
                        } else {
                            return "Failed to save profile: \(error.localizedDescription)"
                        }
                    }()
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
                
                // Verify user is still authenticated
                guard let currentUser = Auth.auth().currentUser, !currentUser.isAnonymous else {
                    print("Save failed: User not authenticated or is anonymous")
                    saveError = NSError(domain: "UserProfileEdit", code: -5, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
                    return
                }
                
                // Debug: Verify authentication token
                let token = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    currentUser.getIDTokenForcingRefresh(true) { token, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let token = token {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: NSError(domain: "UserProfileEdit", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve token"]))
                        }
                    }
                }
                print("Refreshed auth token: \(token.prefix(20))..., bucket: \(Storage.storage().reference().bucket)")
                
                var photoUrl: String? = viewModel.user?.photoUrl
                if let selectedPhoto = selectedPhoto {
                    isLoadingImage = true
                    print("Loading photo data from PhotosPicker")
                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                        print("Save failed: No photo data")
                        saveError = NSError(domain: "UserProfileEdit", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to load photo data"])
                        return
                    }
                    guard let uiImage = UIImage(data: data), uiImage.size.width > 0, uiImage.size.height > 0 else {
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
                    print("Storage path: \(storageRef.fullPath), bucket: \(storageRef.bucket)")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    // Attempt upload with retry logic
                    var lastError: Error?
                    for attempt in 1...3 {
                        do {
                            print("Attempting Storage upload (attempt \(attempt))")
                            guard Auth.auth().currentUser != nil else {
                                throw NSError(domain: "UserProfileEdit", code: -5, userInfo: [NSLocalizedDescriptionKey: "Not authenticated for Storage upload"])
                            }
                            _ = try await storageRef.putDataAsync(resizedData, metadata: metadata)
                            photoUrl = try await storageRef.downloadURL().absoluteString
                            print("Uploaded new photoUrl: \(photoUrl ?? "nil")")
                            ProfileImageCache.shared.setImage(resizedImage!, forKey: photoUrl!)
                            print("Cached new image: \(photoUrl!)")
                            break
                        } catch {
                            lastError = error
                            print("Upload attempt \(attempt) failed: \(error)")
                            if attempt == 3 {
                                saveError = lastError
                                return
                            }
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay
                        }
                    }
                    
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

extension Data {
    var imageType: String? {
        guard count > 0 else { return nil }
        let firstByte = self[0]
        switch firstByte {
        case 0xFF:
            return "jpeg"
        case 0x89:
            return "png"
        default:
            return nil
        }
    }
}

extension PHAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .limited: return "limited"
        @unknown default: return "unknown"
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
