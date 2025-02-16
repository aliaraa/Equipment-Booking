//
//  CartItem.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let tool: Tool
    var quantity: Int
    var pickupDate: Date
    var returnDate: Date
}
