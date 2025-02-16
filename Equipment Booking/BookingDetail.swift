//
//  BookingDetail.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-02-12.
//

import Foundation

struct Booking: Identifiable {
    let id: String
    let toolId: String
    let userId: String
    let startDate: Date
    let endDate: Date
    let quantity: Int
    
    // Initiera en bokning
    init(id: String = UUID().uuidString, toolId: String, userId: String, startDate: Date, endDate: Date, quantity: Int) {
        self.id = id
        self.toolId = toolId
        self.userId = userId
        self.startDate = startDate
        self.endDate = endDate
        self.quantity = quantity
    }
}
