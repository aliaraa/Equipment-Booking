//
//  CartView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

// Changes: Added "Confirm Booking" with Firebase sync and improved UI

import SwiftUI
import FirebaseFirestore

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var equipmentManager: EquipmentDataManager
    @StateObject private var rentalManager = RentalManager.shared
    @Environment(\.dismiss) var dismiss // For sheet dismissal
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if cartManager.cartItems.isEmpty {
                    Text("Your cart is empty")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(cartManager.cartItems) { item in
                            CartRow(item: item)
                        }
                        .onDelete(perform: cartManager.removeFromCart)
                    }
                }
                
                Spacer()
                
                if !cartManager.cartItems.isEmpty {
                    HStack(spacing: 20) {
                        // Clear Cart button
                        Button(action: {
                            cartManager.clearCart()
                            dismiss() // Dismiss sheet and return to TabsView
                        }) {
                            Text("Clear Cart")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                        
                        // Confirm button (existing)
                        Button(action: {
                            Task {
                                do {
                                    let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                    let rental = cartManager.prepareRental(userId: userId)
                                    try await rentalManager.saveRental(rental)
                                    cartManager.clearCart()
                                    showConfirmation = true
                                } catch {
                                    print("Error confirming rental: \(error)")
                                }
                            }
                        }) {
                            Text("Confirm")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Cart")
            .alert("Rental Confirmed", isPresented: $showConfirmation) {
                Button("OK") { dismiss() } // Dismiss after confirmation
            } message: {
                Text("Your rental has been successfully booked.")
            }
        }
    }
}

struct CartRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        HStack {
            Text(item.tool.name)
            Spacer()
            Stepper(value: Binding(
                get: { item.quantity },
                set: { cartManager.updateQuantity(for: item.tool, quantity: $0) }
            ), in: 0...item.tool.numberOfItems) {
                Text("\(item.quantity)")
            }
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
        .environmentObject(EquipmentDataManager())
}

