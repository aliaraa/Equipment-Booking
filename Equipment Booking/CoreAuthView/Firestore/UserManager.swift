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
struct DBUser: Codable {
    
    let userId : String
    let isAnonymous : Bool?
    let email : String?
    let photoUrl : String?
    let dateCreated : Date?
    let isAdmin : Bool?
    
    init (auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date() // current no dateCreated attribute in auth!
        self.isAdmin = false // user is regular by default
        
    }
    
    init(
        userId : String,
        isAnonymous : Bool? = nil,
        email : String? = nil,
        photoUrl : String? = nil,
        dateCreated : Date? = nil,
        isAdmin : Bool? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated // current no dateCreated attribute in auth!
        self.isAdmin = isAdmin // user is regular by default
        
    }
    
    /*
    let firstName : String?
    let lastName : String?
    let isAdmin : Bool
     */
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    //function to get document/user for a given userID
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    } ()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    } ()
    
    func createNewUser(user: DBUser) async  throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        
    }
        
    
  /*
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
        try await userDocument(userId: auth.uid).setData(userData, merge: false)
        
    }
    */
    
    func getUser(userID: String) async throws -> DBUser {
        try await userDocument(userId: userID).getDocument(as: DBUser.self, decoder: decoder) //Decode to DBUser format
        
    }
    
    /*
    func getUser(userID: String) async throws -> DBUser {
        let snapshot = try await userDocument(userId: userID).getDocument()
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
    */
    
    //function to update user privileges
    func updateUserAdminStatus(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    
}
