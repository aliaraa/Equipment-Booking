//
//  UserManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift


//struct DBUser: Codable {
//    let userId: String
//    let isAnonymous: Bool?
//    let email: String?
//    let photoUrl: String?
//    let dateCreated: Date?
//    let isAdmin: Bool?
//    let firstName: String?
//    let lastName: String?
//    let phone: String?          // New field
//    let address: String?        // New field
//    let companyName: String?    // New field
//    let profession: String?     // New field
//
//    init(auth: AuthDataResultModel) {
//        self.userId = auth.uid
//        self.isAnonymous = auth.isAnonymous
//        self.email = auth.email
//        self.photoUrl = auth.photoUrl
//        self.dateCreated = Date()
//        self.isAdmin = false
//        self.firstName = auth.firstName
//        self.lastName = auth.lastName
//        self.phone = ""
//        self.address = ""
//        self.companyName = ""
//        self.profession = ""
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case userId = "doc_id"
//        case isAnonymous = "is_anonymous"
//        case email = "email"
//        case photoUrl = "img_url"
//        case dateCreated = "date_created"
//        case isAdmin = "is_admin"
//        case firstName = "firstname"
//        case lastName = "lastname"
//        case phone = "phone"
//        case address = "address"
//        case companyName = "company_name"
//        case profession = "profession"
//    }
//}


struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String? // Corresponds to 'img_url'
    let dateCreated: Date? // Optional, as Firestore does not provide this by default
    let isAdmin: Bool? // Corresponds to 'is_admin', decoded from both string and boolean
    let firstName: String? // Corresponds to 'firstname'
    let lastName: String? // Corresponds to 'lastname'
    let phone: String?
    let address: String?
    let companyName: String?
    let profession: String?
    

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date() // Placeholder, as Firestore does not include dateCreated
        self.isAdmin = false // Default to false for new users
        self.firstName = auth.firstName ?? ""
        self.lastName = auth.lastName ?? ""
        self.phone = auth.phone ?? ""
        self.address = auth.address ?? ""
        self.companyName = auth.companyName ?? ""
        self.profession = auth.profession ?? ""
    }

    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isAdmin: Bool? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        companyName: String? = nil,
        profession: String? = nil
        
        
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isAdmin = isAdmin
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.address = address
        self.companyName = companyName
        self.profession = profession
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        
        // Decode 'is_admin' as either Bool or String
        if let isAdminBool = try? container.decode(Bool.self, forKey: .isAdmin) {
            self.isAdmin = isAdminBool
        } else if let isAdminString = try? container.decode(String.self, forKey: .isAdmin), let isAdminBool = Bool(isAdminString) {
            self.isAdmin = isAdminBool
        } else {
            self.isAdmin = nil
        }

        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.companyName = try container.decodeIfPresent(String.self, forKey: .companyName)
        self.profession = try container.decodeIfPresent(String.self, forKey: .profession)
    }

    enum CodingKeys: String, CodingKey {
        case userId = "doc_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "img_url"
        case dateCreated = "date_created"
        case isAdmin = "is_admin" // Matches 'is_admin' in Firestore
        case firstName = "firstname"
        case lastName = "lastname"
        case phone = "phone"
        case address = "address"
        case companyName = "company_name" // Matches 'companty_name' in Firestore
        case profession = "profession"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.phone, forKey: .phone)
        try container.encodeIfPresent(self.address, forKey: .address)
        try container.encodeIfPresent(self.companyName, forKey: .companyName)
        try container.encodeIfPresent(self.profession, forKey: .profession)
    }
}



final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    //function to get document/user for a given userID
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }


    
    func createNewUser(user: DBUser) async  throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false )
        
    }
    
    func getUser(userID: String) async throws -> DBUser {
        let documentSnapshot = try await userDocument(userId: userID).getDocument()
        print("Raw Firestore data: \(documentSnapshot.data() ?? [:])") // Debugging line

        do {
            return try documentSnapshot.data(as: DBUser.self) // Decode to DBUser format
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }


    
//    func getUser(userID: String) async throws -> DBUser {
//        try await userDocument(userId: userID).getDocument(as: DBUser.self ) //Decode to DBUser format
//        
//    }
     
    
    func updateUserAdminStatus(userId: String, isAdmin: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isAdmin.rawValue: isAdmin
        ]
        try userDocument(userId: userId).updateData(data)
    }
    
}
