//
//  EquipmentList.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//


// We need to use FB database

import Foundation
import Firebase

//Get toolData from fb

@MainActor
final class EquipmentDataManager: ObservableObject {
    @Published var toolData: [Tool] = []  // Holds all equipment data
    private let equipmentViewModel = EquipmentListingViewModel()
    
    init() {
        fetchEquipmentFromFirebase()
    }
    
    // Fetches equipment from Firebase and stores it in `toolData`.
    func fetchEquipmentFromFirebase() {
        Task {
            do {
                try await equipmentViewModel.fetchEquipments()
                DispatchQueue.main.async {
                    self.toolData = self.equipmentViewModel.equipments
                }
            } catch {
                print(" Error fetching equipment from Firebase: \(error.localizedDescription)")
            }
        }
    }
}



//let toolData: [Tool] = [
//    Tool(name: "Drill Machine",
//         description: "High-power drill machine",
//         price: 10,
//         isAvailable: true,
//         category: "Industrial"),
//    Tool(name: "Hammer",
//         description: "Heavy-duty hammer",
//         price: 4,
//         isAvailable: true,
//         category: "Electrical"),
//    Tool(name: "Screwdriver Set",
//         description: "Set of precision screwdrivers",
//         price: 6,
//         isAvailable: false,
//         category: "Construction")
//]
