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
    private let rentalsCollection = Firestore.firestore().collection("rentals")
    
    private init() {}
    
    func saveRental(_ rental: Rental) async throws {
        try await rentalsCollection.document(rental.id).setData(from: rental)
    }
    
    func fetchUserRentals(userId: String) async throws -> [Rental] {
        let snapshot = try await rentalsCollection
            .whereField("user_id", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Rental.self) }
    }
    
    func returnRental(rentalId: String, items: [RentalItem]) async throws {
        try await rentalsCollection.document(rentalId).updateData([
            "status": "returned"
        ])
    }
}
