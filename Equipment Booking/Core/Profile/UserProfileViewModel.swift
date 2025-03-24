//
//  UserProfileViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserProfileViewModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var user: DBUser? = nil // Current user data from Firestore
    @Published var authUser: AuthDataResultModel? = nil // Authenticated user data
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Methods
    
    /// Loads the current user's data from Firebase Auth and Firestore
    func loadCurrentUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
            print("Loaded user photoUrl: \(self.user?.photoUrl ?? "nil")") // Debug
            
            // Handle missing firstName or lastName
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
    
    /// Updates the user's profile in Firestore
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
            updatedData["img_url"] = photoUrl // Matches DBUser CodingKeys
        } else if user?.photoUrl == nil {
            updatedData["img_url"] = FieldValue.delete()
        }
        
        try await userRef.updateData(updatedData)
        print("User profile updated with photoUrl: \(photoUrl ?? "nil")")
        
        // Explicitly reload user data to ensure UI updates
        self.user = try await UserManager.shared.getUser(userID: userId)
    }
}

// MARK: - Preview Support (Optional)
#if DEBUG
extension UserProfileViewModel {
    static func preview() -> UserProfileViewModel {
        let vm = UserProfileViewModel()
        vm.user = DBUser(
            userId: "test123",
            email: "test@example.com",
            photoUrl: nil,
            firstName: "Test",
            lastName: "User"
        )
        return vm
    }
}
#endif
