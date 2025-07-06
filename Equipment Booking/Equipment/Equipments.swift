//
//  Equipments.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//

import Foundation

// Equipment item fetched from Firebase, updated to ensure availability fields are mutable
// Updated structure to include a "keywords" field for Firestore serialization


struct Tool: Identifiable, Codable {
    let id: String
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
    var numberOfItems: Int
    var isAvailable: Bool
    let keywords: [String]? // New field for server-side search
    
    // Failable initializer from Firebase data
    init?(from data: [String: Any]) {
        guard let id = data["equip_id"] as? String,
              let name = data["name"] as? String,
              let category = data["category"] as? String,
              let mainCategory = data["equipment_main_category"] as? String,
              let subCategory = data["equipment_sub_category"] as? String,
              let description = data["description"] as? String,
              let manufacturer = data["manufacturer"] as? String,
              let status = data["status"] as? String,
              let price = data["price"] as? Double,
              let numberOfItems = data["number_of_items"] as? Int,
              let isAvailable = data["available"] as? Bool else {
            print("Failed to parse document: \(data)")
            return nil
        }
        
        self.id = id
        self.name = name
        self.category = category
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.description = description
        self.manufacturer = manufacturer
        self.imageName = data["img_name"] as? String
        self.imageURL = data["img_url"] as? String
        self.status = status
        self.price = price
        self.numberOfItems = numberOfItems
        self.isAvailable = isAvailable
        self.keywords = data["keywords"] as? [String]
    }
    
    // Manual initializer for testing or local creation
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
        isAvailable: Bool,
        keywords: [String]? = nil
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
        self.keywords = keywords
    }
    
    // CodingKeys for Firebase serialization
    enum CodingKeys: String, CodingKey {
        case id = "equip_id"
        case name
        case category
        case mainCategory = "equipment_main_category"
        case subCategory = "equipment_sub_category"
        case description
        case manufacturer
        case imageName = "img_name"
        case imageURL = "img_url"
        case status
        case price
        case numberOfItems = "number_of_items"
        case isAvailable = "available"
        case keywords
    }
}

