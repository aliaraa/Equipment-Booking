//
//  UserProfileViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var authUser: AuthDataResultModel? = nil
    @Published var profileImage: UIImage? = nil
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    
    private var listener: ListenerRegistration?
    
    struct Notification: Identifiable {
        let id: String
        let title: String
        let body: String
        let rentalId: String
        let timestamp: Date
        var isRead: Bool
    }
    
    init() {}
    
    func loadCurrentUser(forceServer: Bool = false) async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid, forceServer: forceServer)
            print("Loaded user: firstName=\(self.user?.firstName ?? "nil"), photoUrl=\(self.user?.photoUrl ?? "nil")")
            await loadProfileImage()
            await loadNotifications()
            
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
            print("Failed to load user: \(error)")
            self.user = DBUser(
                userId: "unknown",
                email: "Unknown User",
                photoUrl: nil,
                dateCreated: Date(),
                firstName: "Anonymous",
                lastName: "User"
            )
        }
    }
    //  Sync user and reload the image
    //  Fetches user with forceServer: true to get the new img_url.
    //  Clears cache and profileImage, then reloads the image.
    func updateUserProfile(firstName: String?, lastName: String?, phone: String?, address: String?, companyName: String?, profession: String?, photoUrl: String?) async throws {
        guard let userId = user?.userId else {
            print("No user ID available for update")
            throw NSError(domain: "UserProfile", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID"])
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        var updatedData: [String: Any] = [
            "firstname": firstName ?? FieldValue.delete(),
            "lastname": lastName ?? FieldValue.delete(),
            "phone": phone ?? FieldValue.delete(),
            "address": address ?? FieldValue.delete(),
            "company_name": companyName ?? FieldValue.delete(),
            "profession": profession ?? FieldValue.delete()
        ]
        if let photoUrl = photoUrl {
            updatedData["img_url"] = photoUrl
        } else {
            updatedData["img_url"] = FieldValue.delete()
        }
        try await userRef.updateData(updatedData)
        print("Updated Firestore profile: firstName=\(firstName ?? "nil"), photoUrl=\(photoUrl ?? "nil")")
        
        self.user = try await UserManager.shared.getUser(userID: userId, forceServer: true)
        if let oldPhotoUrl = user?.photoUrl, oldPhotoUrl != photoUrl {
            ProfileImageCache.shared.removeImage(forKey: oldPhotoUrl)
        }
        self.profileImage = nil
        await loadProfileImage()
    }
    

    
    func loadNotifications() async {
        guard let userId = user?.userId else {
            print("No user ID for notifications")
            return
        }
        let db = Firestore.firestore()
        listener?.remove()
        listener = db.collection("users").document(userId).collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Failed to load notifications: \(error)")
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.notifications = docs.map { doc in
                    let data = doc.data()
                    return Notification(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        body: data["body"] as? String ?? "",
                        rentalId: data["rentalId"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                }
                self.unreadCount = self.notifications.filter { !$0.isRead }.count
            }
    }
    
    func markNotificationAsRead(id: String, rentalId: String) async {
        guard let userId = user?.userId else {
            print("No user ID to mark notification")
            return
        }
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(userId).collection("notifications")
                .document(id).updateData(["isRead": true])
            try await db.collection("rentals").document(rentalId)
                .updateData(["notification_opened": true])
            print("Marked notification \(id) as read and opened for rental \(rentalId)")
        } catch {
            print("Failed to mark notification: \(error)")
        }
    }
    
    private func loadProfileImage() async {
        guard let photoUrl = user?.photoUrl, let url = URL(string: photoUrl) else {
            self.profileImage = nil
            print("No photoUrl to load image")
            return
        }
        let cacheKey = photoUrl
        if let cachedImage = ProfileImageCache.shared.getImage(forKey: cacheKey) {
            self.profileImage = cachedImage
            print("Loaded profile image from cache: \(cacheKey)")
        } else {
            if let image = await loadImage(from: url) {
                self.profileImage = image
                ProfileImageCache.shared.setImage(image, forKey: cacheKey)
                print("Loaded and cached profile image: \(cacheKey)")
            } else {
                self.profileImage = nil
                print("Failed to load image for: \(cacheKey)")
            }
        }
    }
    
    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image from \(url): \(error)")
            return nil
        }
    }
    
    deinit {
        listener?.remove()
    }
}
