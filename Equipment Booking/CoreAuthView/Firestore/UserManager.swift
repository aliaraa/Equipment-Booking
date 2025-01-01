//
//  UserManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

//create struct for users data from firestore collection
struct DBUser {
    
    let userId : String
    let isAnonymous : Bool?
    let email : String?
    let photoUrl : String?
    let dateCreated : Date?
    
    /*
    let firstName : String?
    let lastName : String?
    let isAdmin : Bool
     */
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData : [String: Any] = [
            "user_id": auth.uid,
            "is_anonymous": auth.isAnonymous,
            "date_created": Timestamp(),
            
        ]
        
        if let email = auth.email {
            userData["email"] = email
        }
        
        if let photoUrl = auth.photoUrl {
            userData["profileImageUrl"] = photoUrl
        }
        
       /*
        if let firstName = auth.firstName {
            userData["firstname"] = firstName
        }
        
        if let lastName = auth.lastName {
            userData["lastname"] = lastName
        }
        
        if let isAdmin = auth.isAdmin {
            userData["is_admin"] = isadmin
        */
        
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userID: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userID).getDocument()
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let isAnonymous = data["is_anonymous"] as? Bool
        let email = data["email"] as? String
        let photoUrl = data["profileImageUrl"] as? String
        let dateCreated = data["date_created"] as? Date
        
        /*
        let isAdmin = data["is_admin"] as? Date
        let firstName = data["firstname"] as? String
        let lastName = data["lastname"] as? String
        */
        
        
        return DBUser(userId: userID, isAnonymous: isAnonymous, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
        
    }
    
}
