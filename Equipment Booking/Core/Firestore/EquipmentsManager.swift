//
//  EquipmentsManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

final class EquipmentManager {
    
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
    
}
