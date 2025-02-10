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
    
    @Published var equipments: [Equipment] = []
    
    private var db = Firestore.firestore()
      
    
    func fetchEquipments() {
        db.collection("equipments").getDocuments {
            (snapshot, error) in
            if let error = error {
                print("Error fetching equipments: \(error)")
                return
                
            }
            
            guard let documents = snapshot?.documents else {
                print("No document found")
                
                return
            }
            
            self.equipments = documents.compactMap { document -> Equipment? in
                let data = document.data()

                // Safely unwrap and cast each field
                let equip_id = data["equip_id"] as? String ?? "unknown"
                let availability_status = data["availability_status"] as? String
                let description = data["description"] as? String
                let equipment_main_category = data["equipment_main_category"] as? String
                let equipment_sub_category = data["equipment_sub_category"] as? String
                let equipment_name = data["equipment_name"] as? String
                let img_name = data["img_name"] as? String
                let img_url = data["img_url"] as? String
                let manufacturer = data["manufacturer"] as? String

                // Handle rental_price_per_day as Double? or nil
                var rental_price_per_day: Double? = nil
                if let price = data["rental_price_per_day"] as? Double {
                    rental_price_per_day = price
                } else if let priceString = data["rental_price_per_day"] as? String, let price = Double(priceString) {
                    rental_price_per_day = price
                }

                return Equipment(
                    equip_id: equip_id,
                    availability_status: availability_status,
                    description: description,
                    equipment_main_category: equipment_main_category,
                    equipment_sub_category: equipment_sub_category,
                    equipment_name: equipment_name,
                    img_name: img_name,
                    img_url: img_url,
                    manufacturer: manufacturer,
                    rental_price_per_day: rental_price_per_day
                )
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
    
}

