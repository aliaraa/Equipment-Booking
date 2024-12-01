//
//  Equipments.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//

import Foundation
struct Tool: Identifiable{
    var id = UUID()
    var name: String
    var description: String
    var price: Int
    var isAvailable: Bool
}
