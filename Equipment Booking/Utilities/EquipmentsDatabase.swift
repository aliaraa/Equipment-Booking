//
//  EquipmentsDatabase.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import Foundation

struct EquipmentArray: Codable {
    let equipments: [Equipment]
    let total, skip, limit: Int
}

struct Equipment: Identifiable, Codable {
    var equip_id: String // unique id
    var id: String {equip_id} // conform to Identifiable by mapping 'id' to 'equip_id'
    var availability_status: String?
    var description: String?
    var category: String?
    var equipment_main_category: String?
    var equipment_sub_category: String?
    var equipment_name: String?
    var img_name: String?
    var img_url: String?
    var manufacturer: String?
    var rental_price_per_day: Double?
    
}

final class EquipmentsDatabase {
    
    static let equipments: [Equipment] = [
        Equipment(equip_id: "CC-C-2", availability_status: "available", description: "The Liebherr 32 TTR is the crane for you who value maximum flexibility and mobility. This crawler construction crane with self-elevating properties expands your possibilities to get ahead on the jobsite.", category: "Construction", equipment_main_category: "Construction Cranes", equipment_sub_category: "Crawler", equipment_name: "Liebherr 32 TTR", img_name: "712322-31.Jpg", img_url: "https://storage.googleapis.com/equipment-management-db.firebasestorage.app/Equipment_imgs/712322-31.Jpg", manufacturer: "Liebherr", rental_price_per_day: 100),
        
    ]
}
