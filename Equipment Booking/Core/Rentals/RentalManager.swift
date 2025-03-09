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
    private let equipmentsCollection = Firestore.firestore().collection("equipments")
    
    private init() {}
    
    func saveRental(_ rental: Rental) async throws {
        try await rentalsCollection.document(rental.id).setData(from: rental)
        for item in rental.items {
            // Updated to use item.id
            let equipmentRef = equipmentsCollection.document(item.id)
            let snapshot = try await equipmentRef.getDocument()
            guard let data = snapshot.data() else {
                throw NSError(domain: "RentalManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Equipment data not found"])
            }
            guard var tool = Tool(from: data) else {
                throw NSError(domain: "RentalManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid equipment data"])
            }
            let newQuantity = max(0, tool.numberOfItems - item.quantity)
            let isAvailable = newQuantity > 0
            try await equipmentRef.updateData([
                "number_of_items": newQuantity,
                "available": isAvailable
            ])
        }
    }
    
    func fetchUserRentals(userId: String) async throws -> [Rental] {
        let snapshot = try await rentalsCollection
            .whereField("user_id", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Rental.self) }
    }
    
    func returnRental(rentalId: String, items: [RentalItem]) async throws {
        try await rentalsCollection.document(rentalId).updateData([
            "status": "returned"
        ])
        for item in items {
            // Updated to use item.id
            let equipmentRef = equipmentsCollection.document(item.id)
            let snapshot = try await equipmentRef.getDocument()
            guard let data = snapshot.data() else {
                throw NSError(domain: "RentalManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Equipment data not found"])
            }
            guard var tool = Tool(from: data) else {
                throw NSError(domain: "RentalManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid equipment data"])
            }
            let newQuantity = tool.numberOfItems + item.quantity
            let isAvailable = newQuantity > 0
            try await equipmentRef.updateData([
                "number_of_items": newQuantity,
                "available": isAvailable
            ])
        }
    }
}
