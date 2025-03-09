//
//  CartItem.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import Foundation

// Represents an item in the cart with rental dates
struct CartItem: Identifiable, Codable {
    let id = UUID()
    let tool: Tool
    var quantity: Int
    let pickupDate: Date  // Added for rental period
    let returnDate: Date  // Added for rental period
    
    // CodingKeys for potential Firebase serialization
    enum CodingKeys: String, CodingKey {
        case id
        case tool
        case quantity
        case pickupDate = "pickup_date"
        case returnDate = "return_date"
    }
}

