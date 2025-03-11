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
    @Published private(set) var user: DBUser? = nil // Current user data from Firestore, read-only externally
    @Published var authUser: AuthDataResultModel? = nil // Authenticated user data from Firebase Auth
    
    // MARK: - Initialization
    init() {
        // No initial load here; defer to loadCurrentUser() for explicit control
    }
    
    // MARK: - Methods
    
    /// Loads the current user's data from Firebase Auth and Firestore, handling missing names gracefully
    func loadCurrentUser() async {
        do {
            // Fetch authenticated user from Firebase Auth
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            
            // Fetch user profile from Firestore
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
            
            // Handle missing firstName or lastName
            if user?.firstName == nil || user?.lastName == nil {
                if let googleProfile = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "google.com" }) {
                    // Extract names from Google profile if available
                    let firstName = googleProfile.displayName?.components(separatedBy: " ").first
                    let lastName = googleProfile.displayName?.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let photoUrl = googleProfile.photoURL?.absoluteString
                    
                    // Update user with Google data or fallback to email
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: photoUrl ?? authDataResult.photoUrl,
                        firstName: firstName ?? authDataResult.email,
                        lastName: lastName
                    )
                } else {
                    // Fallback to email as firstName if no Google profile
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: authDataResult.photoUrl,
                        firstName: authDataResult.email,
                        lastName: nil
                    )
                }
                
                // Persist the updated user to Firestore if modified
                if let updatedUser = self.user {
                    try await UserManager.shared.createNewUser(user: updatedUser)
                }
            }
        } catch {
            print("Failed to load user: \(error.localizedDescription)")
            // Fallback to a default anonymous user in case of error
            self.user = DBUser(
                userId: "unknown",
                email: "Unknown User",
                firstName: "Anonymous",
                lastName: "User"
            )
        }
    }
    
    /// Updates the user's profile in Firestore with new values
    /// - Parameters:
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    ///   - phone: User's phone number
    ///   - address: User's address
    ///   - companyName: User's company name
    ///   - profession: User's profession
    func updateUserProfile(firstName: String, lastName: String, phone: String, address: String, companyName: String, profession: String) async throws {
        guard let userId = user?.userId else {
            print("No user ID available for update")
            return
        }
        
        // Prepare updated data for Firestore
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        let updatedData: [String: Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "phone": phone,
            "address": address,
            "company_name": companyName,
            "profession": profession
        ]
        
        // Update Firestore document
        try await userRef.updateData(updatedData)
        print("User profile updated successfully.")
        
        // Refresh local user data after update
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

//@MainActor
//final class UserProfileViewModel: ObservableObject {
//    @Published private(set) var user: DBUser? = nil
//    @Published var authUser: AuthDataResultModel? = nil
//        
//    
//    func loadCurrentUser() async {
//        do {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.authUser = authDataResult
//            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
//
//            // Handle missing first name and last name
//            if user?.firstName == nil || user?.lastName == nil {
//                if let googleProfile = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "google.com" }) {
//                    // Try to get names and photo from Google profile
//                    let firstName = googleProfile.displayName?.components(separatedBy: " ").first
//                    let lastName = googleProfile.displayName?.components(separatedBy: " ").dropFirst().joined(separator: " ")
//                    let photoUrl = googleProfile.photoURL?.absoluteString
//                    
//                    // Update user instance
//                    self.user = DBUser(
//                        userId: authDataResult.uid,
//                        email: authDataResult.email,
//                        photoUrl: photoUrl ?? authDataResult.photoUrl,
//                        firstName: firstName ?? authDataResult.email,
//                        lastName: lastName
//                        
//                    )
//                } else {
//                    // Default to email if name is missing
//                    self.user = DBUser(
//                        userId: authDataResult.uid,
//                        email: authDataResult.email,
//                        photoUrl: authDataResult.photoUrl,
//                        firstName: authDataResult.email,
//                        lastName: nil
//                        
//                    )
//                }
//            }
//        } catch {
//            print("Failed to load user: \(error.localizedDescription)")
//            self.user = DBUser(
//                userId: "unknown",
//                email: "Unknown User",
//                firstName: "Anonymous",
//                lastName: "User"
//            )
//        }
//    }
//    
//    func updateUserProfile(firstName: String, lastName: String, phone: String, address: String, companyName: String, profession: String) async throws {
//            guard let userId = user?.userId else { return }
//
//            let db = Firestore.firestore()
//            let userRef = db.collection("users").document(userId)
//
//            let updatedData: [String: Any] = [
//                "firstname": firstName,
//                "lastname": lastName,
//                "phone": phone,
//                "address": address,
//                "company_name": companyName,
//                "profession": profession
//            ]
//
//            try await userRef.updateData(updatedData)
//            print("User profile updated successfully.")
//        }
//    
//}
