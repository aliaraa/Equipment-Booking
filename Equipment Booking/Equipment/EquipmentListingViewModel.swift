//
//  EquipmentListingViewModel.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import Foundation
import Firebase
import FirebaseFirestore


@MainActor
final class EquipmentListingViewModel: ObservableObject {
    @Published var equipments: [Tool] = []  // Stores fetched equipment data
    private var db = Firestore.firestore()  // Reference to Firestore database
    
    // Fetches equipment data from Firebase and updates `equipments`.
    func fetchEquipments() async throws {
        let snapshot = try await db.collection("equipments").getDocuments()
        
        // Map Firebase data to Tool objects
        let fetchedEquipments = snapshot.documents.compactMap { document -> Tool? in
            let data = document.data()
            return Tool(from: data)  // Convert each Firebase document into a Tool object
        }
        
        // Update the published state variable
        DispatchQueue.main.async {
            self.equipments = fetchedEquipments
        }
    }
}


    
    //Booking ID Generation Function:
    
    func generateBookingID(firstName: String, lastName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let dateStr = dateFormatter.string(from: Date())
        let id = "\(firstName.prefix(1))\(lastName.prefix(2).uppercased())\(dateStr)"
        return id
    }
    


