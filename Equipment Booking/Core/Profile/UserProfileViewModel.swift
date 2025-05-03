//
//  UserProfileViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

class UserProfileViewModel: ObservableObject {
    @Published var user: DBUser?
    @Published var authUser: AuthDataResultModel?
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    
    private let db = Firestore.firestore()
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var isLoadingUser = false
    private var lastLoadedUserId: String?
    
    init() {
        setupAuthListener()
    }
    
    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthListener() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let firebaseUser = firebaseUser {
                let authUser = AuthDataResultModel(user: firebaseUser)
                Task {
                    await MainActor.run { self.authUser = authUser }
                    await self.loadCurrentUser(userId: authUser.uid, forceServer: true)
                    print("Auth state changed: UID=\(authUser.uid), email=\(authUser.email ?? "nil")")
                }
            } else {
                Task {
                    await MainActor.run {
                        self.authUser = nil
                        self.user = nil
                        self.notifications = []
                        self.unreadCount = 0
                        self.lastLoadedUserId = nil
                    }
                    print("Auth state changed: User signed out")
                }
            }
        }
    }
    
    func loadCurrentUser(userId: String? = nil, forceServer: Bool = false) async {
        guard !isLoadingUser else {
            print("Skipping loadCurrentUser: already in progress")
            return
        }
        let uid = userId ?? Auth.auth().currentUser?.uid
        guard let uid = uid else {
            print("No authenticated user")
            await MainActor.run { self.user = nil }
            return
        }
        if !forceServer, lastLoadedUserId == uid {
            print("Skipping loadCurrentUser: user \(uid) already loaded")
            return
        }
        isLoadingUser = true
        defer { isLoadingUser = false }
        
        do {
            let dbUser = try await UserManager.shared.getUser(userID: uid, forceServer: forceServer)
            print("Loaded user: firstName=\(dbUser.firstName ?? "nil"), photoUrl=\(dbUser.photoUrl ?? "nil")")
            await MainActor.run {
                self.user = dbUser
                self.lastLoadedUserId = uid
            }
            
            // CHANGE: Pre-fetch and cache profile image
            if let photoUrl = dbUser.photoUrl, !photoUrl.isEmpty {
                await cacheProfileImage(url: photoUrl)
            } else {
                guard Auth.auth().currentUser != nil else {
                    print("Cannot fetch photoUrl: No authenticated user")
                    return
                }
                let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
                do {
                    let url = try await storageRef.downloadURL()
                    print("Fetched photoUrl from Storage: \(url.absoluteString)")
                    try await UserManager.shared.updateUser(
                        userId: uid,
                        firstName: dbUser.firstName,
                        lastName: dbUser.lastName,
                        phone: dbUser.phone,
                        address: dbUser.address,
                        companyName: dbUser.companyName,
                        profession: dbUser.profession,
                        photoUrl: url.absoluteString
                    )
                    await MainActor.run { self.user?.photoUrl = url.absoluteString }
                    await cacheProfileImage(url: url.absoluteString)
                    print("Updated Firestore with photoUrl: \(url.absoluteString)")
                } catch {
                    print("Failed to fetch photoUrl from Storage: \(error)")
                }
            }
        } catch {
            print("Failed to load user: \(error)")
            await MainActor.run { self.user = nil }
        }
    }
    
    // CHANGE: Cache profile image
    private func cacheProfileImage(url: String) async {
        if ProfileImageCache.shared.getImage(forKey: url) != nil {
            print("Image already cached for: \(url)")
            return
        }
        guard let imageUrl = URL(string: url) else {
            print("Invalid image URL: \(url)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            guard let uiImage = UIImage(data: data) else {
                print("Failed to create UIImage from data: \(url)")
                return
            }
            await MainActor.run {
                ProfileImageCache.shared.setImage(uiImage, forKey: url)
                print("Cached image for: \(url)")
            }
        } catch {
            print("Failed to cache image: \(url), error: \(error)")
        }
    }
    
    func updateUserProfile(
        firstName: String?,
        lastName: String?,
        phone: String?,
        address: String?,
        companyName: String?,
        profession: String?,
        photoUrl: String?
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "UserProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        try await UserManager.shared.updateUser(
            userId: uid,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            address: address,
            companyName: companyName,
            profession: profession,
            photoUrl: photoUrl
        )
        await loadCurrentUser(userId: uid, forceServer: true)
    }
    
    func markNotificationAsRead(id: String, rentalId: String?) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await db.collection("users").document(uid)
                .collection("notifications").document(id)
                .updateData(["isRead": true])
            if let rentalId = rentalId {
                try await db.collection("rentals").document(rentalId)
                    .updateData(["isRead": true])
            }
            await loadCurrentUser(forceServer: true)
        } catch {
            print("Failed to mark notification as read: \(error)")
        }
    }
}

struct Notification: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let timestamp: Date
    let isRead: Bool
    let rentalId: String?
}


//class UserProfileViewModel: ObservableObject {
//    @Published var user: DBUser?
//    @Published var authUser: AuthDataResultModel? // CHANGE: Use AuthDataResultModel
//    @Published var notifications: [Notification] = []
//    @Published var unreadCount: Int = 0
//    
//    private let db = Firestore.firestore()
//    private var authListenerHandle: AuthStateDidChangeListenerHandle?
//    
//    init() {
//        setupAuthListener()
//    }
//    
//    deinit {
//        // CHANGE: Remove auth listener to prevent memory leaks
//        if let handle = authListenerHandle {
//            Auth.auth().removeStateDidChangeListener(handle)
//        }
//    }
//    
//    private func setupAuthListener() {
//        // CHANGE: Use Firebase Auth state listener instead of authStatePublisher
//        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
//            guard let self = self else { return }
//            if let firebaseUser = firebaseUser {
//                let authUser = AuthDataResultModel(user: firebaseUser)
//                Task {
//                    await MainActor.run { self.authUser = authUser }
//                    await self.loadCurrentUser(userId: authUser.uid, forceServer: true)
//                    print("Auth state changed: UID=\(authUser.uid), email=\(authUser.email ?? "nil")")
//                }
//            } else {
//                Task {
//                    await MainActor.run {
//                        self.authUser = nil
//                        self.user = nil
//                        self.notifications = []
//                        self.unreadCount = 0
//                    }
//                    print("Auth state changed: User signed out")
//                }
//            }
//        }
//    }
//    
//    func loadCurrentUser(userId: String? = nil, forceServer: Bool = false) async {
//        guard let uid = userId ?? Auth.auth().currentUser?.uid else {
//            print("No authenticated user")
//            await MainActor.run { self.user = nil }
//            return
//        }
//        do {
//            let dbUser = try await UserManager.shared.getUser(userID: uid, forceServer: forceServer)
//            print("Loaded user: firstName=\(dbUser.firstName ?? "nil"), photoUrl=\(dbUser.photoUrl ?? "nil")")
//            await MainActor.run { self.user = dbUser }
//            
//            if dbUser.photoUrl == nil {
//                let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
//                do {
//                    let url = try await storageRef.downloadURL()
//                    print("Fetched photoUrl from Storage: \(url.absoluteString)")
//                    try await UserManager.shared.updateUser(
//                        userId: uid,
//                        firstName: dbUser.firstName,
//                        lastName: dbUser.lastName,
//                        phone: dbUser.phone,
//                        address: dbUser.address,
//                        companyName: dbUser.companyName,
//                        profession: dbUser.profession,
//                        photoUrl: url.absoluteString
//                    )
//                    await MainActor.run { self.user?.photoUrl = url.absoluteString }
//                    print("Updated Firestore with photoUrl: \(url.absoluteString)")
//                } catch {
//                    print("No photo exists in Storage or access denied: \(error)")
//                }
//            }
//        } catch {
//            print("Failed to load user: \(error)")
//            await MainActor.run { self.user = nil }
//        }
//    }
//    
//    func updateUserProfile(
//        firstName: String?,
//        lastName: String?,
//        phone: String?,
//        address: String?,
//        companyName: String?,
//        profession: String?,
//        photoUrl: String?
//    ) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            throw NSError(domain: "UserProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
//        }
//        try await UserManager.shared.updateUser(
//            userId: uid,
//            firstName: firstName,
//            lastName: lastName,
//            phone: phone,
//            address: address,
//            companyName: companyName,
//            profession: profession,
//            photoUrl: photoUrl
//        )
//        await loadCurrentUser(userId: uid, forceServer: true)
//    }
//    
//    func markNotificationAsRead(id: String, rentalId: String?) async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        do {
//            try await db.collection("users").document(uid)
//                .collection("notifications").document(id)
//                .updateData(["isRead": true])
//            if let rentalId = rentalId {
//                try await db.collection("rentals").document(rentalId)
//                    .updateData(["isRead": true])
//            }
//            await loadCurrentUser(forceServer: true)
//        } catch {
//            print("Failed to mark notification as read: \(error)")
//        }
//    }
//}
//
//struct Notification: Identifiable, Codable {
//    let id: String
//    let title: String
//    let body: String
//    let timestamp: Date
//    let isRead: Bool
//    let rentalId: String?
//}



