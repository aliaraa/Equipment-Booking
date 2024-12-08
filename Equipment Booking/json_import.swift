//
//  json_import.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreImporter {
    private let db = Firestore.firestore()

    func importUsers(from fileName: String) {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("JSON file not found")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let users = try JSONDecoder().decode([User].self, from: data)

            for user in users {
                let userDoc: [String: Any] = [
                    "user_id": user.user_id,
                    "first_name": user.first_name,
                    "last_name": user.last_name,
                    "email": user.email,
                    "registration_date": user.registration_date,
                    "user_type": user.user_type,
                    "user_name": user.user_name
                ]

                db.collection("users").document(user.email).setData(userDoc) { error in
                    if let error = error {
                        print("Error adding user: \(error.localizedDescription)")
                    } else {
                        print("Successfully added user: \(user.first_name)")
                    }
                }
            }
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }
}

// MARK: - User Model
struct User: Codable {
    var user_id: Int
    var first_name: String
    var last_name: String
    var email: String
    var registration_date: String
    var user_type: String
    var user_name: String
}
