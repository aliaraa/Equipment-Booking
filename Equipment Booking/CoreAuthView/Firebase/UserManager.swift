//
//  UserManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift


final class UserManager {
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData : [String: Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp(),
            
        ]
        
        if let email = auth.email {
            userData["email"] = email
        }
        
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    
    
    
}
