//
//  EquipmentsManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

@MainActor
final class EquipmentManager: ObservableObject {
    
    static let shared = EquipmentManager()
    private init() {}
    
    private let equipmentsCollection = Firestore.firestore().collection("equipments")
    
    //function to get document/equipment for a given equipmentId
    private func equipmentDocument(equipmentId: String) -> DocumentReference {
        equipmentsCollection.document(equipmentId)
    }
    
    func uploadEquipment(equipment: Equipment) async throws {
        try equipmentDocument(equipmentId: equipment.equip_id).setData(from: equipment, merge: false)
    }
    
    func getAllEquipments() async throws -> [Equipment] {
        let snapshot = try await equipmentsCollection.getDocuments()
        
        var equipments: [Equipment] = []
        for document in snapshot.documents {
            let equipment = try document.data(as: Equipment.self)
            equipments.append(equipment)
        }
        
        return equipments
        
    }
    
    //Booking ID Generation Function:
    
    func generateBookingID(firstName: String, lastName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let dateStr = dateFormatter.string(from: Date())
        let id = "\(firstName.prefix(1))\(lastName.prefix(2).uppercased())\(dateStr)"
        return id
    }
}
