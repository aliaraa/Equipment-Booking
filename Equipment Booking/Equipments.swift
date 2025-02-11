//
//  Equipments.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//

import Foundation

// Equipment item fetched from Firebase.
struct Tool: Identifiable {
    let id: String  // Equipment ID from Firebase
    let name: String
    let category: String
    let mainCategory: String
    let subCategory: String
    let description: String
    let manufacturer: String
    let imageName: String?
    let imageURL: String?
    let status: String
    let price: Double
    let numberOfItems: Int
    let isAvailable: Bool
    
    // Initializes a `Tool` object from Firebase data.
    init(from data: [String: Any]) {
        self.id = data["equip_id"] as? String ?? UUID().uuidString
        self.name = data["name"] as? String ?? "Unknown Equipment"
        self.category = data["category"] as? String ?? "Uncategorized"
        self.mainCategory = data["equipment_main_category"] as? String ?? "Unknown Main Category"
        self.subCategory = data["equipment_sub_category"] as? String ?? "Unknown Sub Category"
        self.description = data["description"] as? String ?? "No description available"
        self.manufacturer = data["manufacturer"] as? String ?? "Unknown Manufacturer"
        self.imageName = data["img_name"] as? String
        self.imageURL = data["img_url"] as? String
        self.status = data["status"] as? String ?? "unknown"
        self.price = data["price"] as? Double ?? 0.0
        self.numberOfItems = data["number_of_items"] as? Int ?? 0
        self.isAvailable = data["available"] as? Bool ?? false
    }
    
    // **New initializer for manual testing**
        init(
            id: String = UUID().uuidString,
            name: String,
            category: String,
            mainCategory: String,
            subCategory: String,
            description: String,
            manufacturer: String,
            imageName: String? = nil,
            imageURL: String? = nil,
            status: String,
            price: Double,
            numberOfItems: Int,
            isAvailable: Bool
        ) {
            self.id = id
            self.name = name
            self.category = category
            self.mainCategory = mainCategory
            self.subCategory = subCategory
            self.description = description
            self.manufacturer = manufacturer
            self.imageName = imageName
            self.imageURL = imageURL
            self.status = status
            self.price = price
            self.numberOfItems = numberOfItems
            self.isAvailable = isAvailable
        }
    
}



//struct Tool: Identifiable{
//    var id = UUID()
//    var name: String
//    var description: String
//    var price: Int
//    var isAvailable: Bool
//    var category: String
//}
