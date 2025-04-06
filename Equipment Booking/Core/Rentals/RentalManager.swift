//
//  RentalManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/9/25.
//

import Foundation
import FirebaseFirestore

@MainActor
final class RentalManager: ObservableObject {
    static let shared = RentalManager()
    private let db = Firestore.firestore()
    private let rentalsCollection = Firestore.firestore().collection("rentals")
    
    private init() {}
    
    func saveRental(_ rental: Rental) async throws {
        let rentalData: [String: Any] = [
            "id": rental.id,
            "user_id": rental.userId,
            "items": rental.items.map { ["tool_id": $0.id, "quantity": $0.quantity] },
            "pickup_date": Timestamp(date: rental.pickupDate),
            "return_date": Timestamp(date: rental.returnDate),
            "status": rental.status,
            "notification_sent": rental.notificationSent ?? false,
            "notification_opened": rental.notificationOpened ?? false
        ]
        try await db.collection("rentals").document(rental.id).setData(rentalData)
    }
    
    func fetchUserRentals(userId: String) async throws -> [Rental] {
        let snapshot = try await rentalsCollection
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Rental.self)
        }
    }
    
    func returnRental(rentalId: String, items: [RentalItem]) async throws {
        try await rentalsCollection.document(rentalId).updateData([
            "status": "returned"
        ])
    }
}
