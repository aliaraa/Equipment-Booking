//
//  Untitled.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//
import SwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    func addToCart(_ tool: Tool, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            // Om verktyget redan finns i kundvagnen, öka kvantiteten
            cartItems[index].quantity += quantity
        } else {
            // Lägg till nytt verktyg i kundvagnen
            cartItems.append(CartItem(tool: tool, quantity: quantity))
        }
    }
    
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    func updateQuantity(for tool: Tool, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            cartItems[index].quantity = quantity
            if cartItems[index].quantity <= 0 {
                cartItems.remove(at: index)
            }
        }
    }
}

