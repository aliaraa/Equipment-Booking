//
//  Untitled.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//


// Refactored to prepare data for Firebase, not act as sole storage

import SwiftUI
import Foundation  // Added for Date and UUID

// Import CartItem from CartItem.swift (assuming it’s in the same module)
class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    // Add a tool to the cart with rental dates
    func addToCart(_ tool: Tool, quantity: Int, pickupDate: Date, returnDate: Date) {
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(tool: tool, quantity: quantity, pickupDate: pickupDate, returnDate: returnDate))
        }
    }
    
    // Remove items from the cart
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    // Update quantity and remove if zero or less
    func updateQuantity(for tool: Tool, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            cartItems[index].quantity = quantity
            if quantity <= 0 {
                cartItems.remove(at: index)
            }
        }
    }
    
    // Prepare rental data for Firebase
    func prepareRental(userId: String) -> Rental {
        // Updated to use id instead of toolId
        let rentalItems = cartItems.map { RentalItem(id: $0.tool.id, quantity: $0.quantity) }
        let pickupDate = cartItems.first?.pickupDate ?? Date()
        let returnDate = cartItems.first?.returnDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return Rental(
            id: UUID().uuidString,
            userId: userId,
            items: rentalItems,
            pickupDate: pickupDate,
            returnDate: returnDate,
            status: "active"
        )
    }
    
    // Clear the cart after successful booking
    func clearCart() {
        cartItems.removeAll()
    }
}

// Rental model for Firebase
struct Rental: Identifiable, Codable {
    let id: String
    let userId: String
    let items: [RentalItem]
    let pickupDate: Date
    let returnDate: Date
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case items
        case pickupDate = "pickup_date"
        case returnDate = "return_date"
        case status
    }
}

// RentalItem for Firebase, conforms to Identifiable
struct RentalItem: Codable, Identifiable {
    let id: String  // Single property for tool identifier
    let quantity: Int
    
    // Updated initializer to use id
    init(id: String, quantity: Int) {
        self.id = id
        self.quantity = quantity
    }
    
    // CodingKeys now maps only id to "tool_id"
    enum CodingKeys: String, CodingKey {
        case id = "tool_id"
        case quantity
    }
}



