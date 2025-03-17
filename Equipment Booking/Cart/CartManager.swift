//
//  Untitled.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//


// Refactored to prepare data for Firebase, not act as sole storage

import SwiftUI
import Foundation  // Added for Date and UUID
//

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    let isReadOnly: Bool // ✅ Added for unauthenticated users to prevent unauthorized user to add items
    
    init(isReadOnly: Bool = false) {
        self.isReadOnly = isReadOnly
    }
    
    // Add a tool to the cart with rental dates
    func addToCart(_ tool: Tool, quantity: Int, pickupDate: Date, returnDate: Date) {
        if isReadOnly {
            print("Sign in to add items to cart")
            return // ✅ Block addition in read-only mode
        }
        
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(tool: tool, quantity: quantity, pickupDate: pickupDate, returnDate: returnDate))
        }
    }
    
    // Remove items from the cart
    func removeFromCart(at offsets: IndexSet) {
        if isReadOnly {
            print("Sign in to modify cart")
            return // ✅ Block removal in read-only mode
        }
        cartItems.remove(atOffsets: offsets)
    }
    
    // Update quantity and remove if zero or less
    func updateQuantity(for tool: Tool, quantity: Int) {
        if isReadOnly {
            print("Sign in to modify cart")
            return // ✅ Block updates in read-only mode
        }
        
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            cartItems[index].quantity = quantity
            if quantity <= 0 {
                cartItems.remove(at: index)
            }
        }
    }
    
    // Prepare rental data for Firebase
    func prepareRental(userId: String) -> Rental {
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
        if isReadOnly {
            print("Sign in to modify cart")
            return // ✅ Block clearing in read-only mode
        }
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
    let id: String
    let quantity: Int
    
    init(id: String, quantity: Int) {
        self.id = id
        self.quantity = quantity
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "tool_id"
        case quantity
    }
}



