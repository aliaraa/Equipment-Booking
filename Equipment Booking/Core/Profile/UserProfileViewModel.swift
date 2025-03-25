//
//  UserProfileViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var authUser: AuthDataResultModel? = nil
    @Published var profileImage: UIImage? = nil
    
    init() {}
    
    func loadCurrentUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
            print("Loaded user photoUrl: \(self.user?.photoUrl ?? "nil")")
            
            // Load profile image from cache or network
            await loadProfileImage()
            
            if user?.firstName == nil || user?.lastName == nil {
                if let googleProfile = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "google.com" }) {
                    let firstName = googleProfile.displayName?.components(separatedBy: " ").first
                    let lastName = googleProfile.displayName?.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let photoUrl = googleProfile.photoURL?.absoluteString
                    
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: photoUrl ?? authDataResult.photoUrl,
                        firstName: firstName ?? authDataResult.email,
                        lastName: lastName
                    )
                    await loadProfileImage()
                } else {
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: authDataResult.photoUrl,
                        firstName: authDataResult.email,
                        lastName: nil
                    )
                }
                
                if let updatedUser = self.user {
                    try await UserManager.shared.createNewUser(user: updatedUser)
                }
            }
        } catch {
            print("Failed to load user: \(error.localizedDescription)")
            self.user = DBUser(
                userId: "unknown",
                email: "Unknown User",
                photoUrl: nil,
                firstName: "Anonymous",
                lastName: "User"
            )
        }
    }
    
    func updateUserProfile(firstName: String, lastName: String, phone: String, address: String, companyName: String, profession: String, photoUrl: String? = nil) async throws {
        guard let userId = user?.userId else {
            print("No user ID available for update")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        var updatedData: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "phone": phone,
            "address": address,
            "company_name": companyName,
            "profession": profession
        ]
        
        if let photoUrl = photoUrl {
            updatedData["img_url"] = photoUrl
        } else if user?.photoUrl == nil {
            updatedData["img_url"] = FieldValue.delete()
        }
        
        try await userRef.updateData(updatedData)
        print("User profile updated with photoUrl: \(photoUrl ?? "nil")")
        
        self.user = try await UserManager.shared.getUser(userID: userId)
        await loadProfileImage()
    }
    
    // Load image from cache or network
    private func loadProfileImage() async {
        guard let photoUrl = user?.photoUrl, let url = URL(string: photoUrl) else {
            self.profileImage = nil
            return
        }
        
        let cacheKey = photoUrl
        if let cachedImage = ProfileImageCache.shared.getImage(forKey: cacheKey) {
            self.profileImage = cachedImage
            print("Loaded profile image from cache")
        } else {
            if let image = await loadImage(from: url) {
                self.profileImage = image
                ProfileImageCache.shared.setImage(image, forKey: cacheKey)
                print("Loaded and cached profile image")
            }
        }
    }
    
    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error.localizedDescription)")
            return nil
        }
    }
}

