//
//  EquipmentsManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

// EquipmentManager.swift
import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

@MainActor
final class EquipmentManager: ObservableObject {
    static let shared = EquipmentManager()
    private init() {}
    
    private let equipmentsCollection = Firestore.firestore().collection("equipments")
    private let rentalsCollection = Firestore.firestore().collection("rentals")
    
    private func equipmentDocument(equipmentId: String) -> DocumentReference {
        equipmentsCollection.document(equipmentId)
    }
    
    func uploadEquipment(tool: Tool) async throws {
        try equipmentDocument(equipmentId: tool.id).setData(from: tool, merge: false)
    }
    
    func getAllEquipments() async throws -> [Tool] {
        let snapshot = try await equipmentsCollection.getDocuments()
        var tools: [Tool] = []
        for document in snapshot.documents {
            let tool = try document.data(as: Tool.self)
            tools.append(tool)
        }
        return tools
    }
    
    func getNextAvailableDate(forToolId toolId: String) async throws -> Date {
        let snapshot = try await rentalsCollection
            .whereField("items.tool_id", arrayContains: toolId)
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        var latestReturnDate: Date = Date()
        for document in snapshot.documents {
            let rental = try document.data(as: Rental.self)
            if rental.returnDate > latestReturnDate {
                latestReturnDate = rental.returnDate
            }
        }
        return Calendar.current.date(byAdding: .day, value: 1, to: latestReturnDate) ?? latestReturnDate
    }
    
    // Uppdaterad getToolAvailability i EquipmentManager.swift
    func getToolAvailability(forToolId toolId: String, pickupDate: Date, returnDate: Date) async throws -> (total: Int, available: Int) {
        let equipmentSnapshot = try await equipmentDocument(equipmentId: toolId).getDocument()
        guard equipmentSnapshot.exists, let tool = try? equipmentSnapshot.data(as: Tool.self) else {
            throw NSError(domain: "EquipmentManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tool not found"])
        }
        let totalQuantity = tool.numberOfItems
        print("Total quantity for \(toolId): \(totalQuantity)")

        // Hämta alla aktiva bokningar och filtrera manuellt
        let snapshot = try await rentalsCollection
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        print("Found \(snapshot.documents.count) active rentals to check for \(toolId)")

        var bookedQuantity = 0
        for document in snapshot.documents {
            let rental = try document.data(as: Rental.self)
            let overlaps = rental.pickupDate <= returnDate && rental.returnDate >= pickupDate
            print("Rental \(document.documentID): pickup \(rental.pickupDate), return \(rental.returnDate), overlaps: \(overlaps)")
            if overlaps {
                if let bookedItem = rental.items.first(where: { $0.id == toolId }) {
                    bookedQuantity += bookedItem.quantity
                    print(" - Booked \(bookedItem.quantity) for \(toolId)")
                }
            }
        }
        print("Total booked for \(toolId) between \(pickupDate) and \(returnDate): \(bookedQuantity)")
        let availableQuantity = max(0, totalQuantity - bookedQuantity)
        print("Available quantity for \(toolId): \(availableQuantity)")
        return (total: totalQuantity, available: availableQuantity)
    }
    
    func generateBookingID(firstName: String, lastName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let dateStr = dateFormatter.string(from: Date())
        return "\(firstName.prefix(1))\(lastName.prefix(2).uppercased())\(dateStr)"
    }
}
