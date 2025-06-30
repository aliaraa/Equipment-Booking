//
//  CartView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

// Changes: Added "Confirm Booking" with Firebase sync and improved UI


import SwiftUI
import FirebaseFirestore

// Improved CartView and CartRow UI for iPhone 14 size
// - Increased CartRow font sizes to 14 pt for details and 16 pt for quantity.
// - Added 16 pt spacing between CartRow sections.
// - Increase CartView bottom VStack spacing to 24 pt and ensure buttons are 44 pt tall.

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var equipmentManager: EquipmentDataManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel // NEW: Access AuthenticationViewModel
    @Environment(\.showSignIn) var showSignIn // NEW: Access showSignIn binding
    @StateObject private var rentalManager = RentalManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmation = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
            NavigationStack {
                VStack {
                    if cartManager.cartItems.isEmpty {
                        Text("Your cart is empty")
//                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .font(Typography.body) // Use Typography for consistent styling
                            .foregroundColor(.gray)
                            .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(cartManager.cartItems) { item in
                                CartRow(item: item)
                            }
                            .onDelete(perform: cartManager.removeFromCart)
                        }
                        .listStyle(.plain)
                    }
                    
                    if !cartManager.cartItems.isEmpty {
                        VStack(spacing: 24) { // Increased spacing
                            Text("Total: \(cartManager.totalCost(), specifier: "%.2f") SEK")
//                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .font(Typography.headline) // Use Typography for consistent styling
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    if authViewModel.isAuthenticated {
                                        cartManager.clearCart()
                                        dismiss()
                                    } else {
                                        showSignIn?.wrappedValue = true
                                    }
                                }) {
                                    Text("Clear Cart")
                                        .font(Typography.headline) // Use Typography for consistent styling
//                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .frame(maxWidth: .infinity, minHeight: 44) // Ensure touch target
                                        .background(authViewModel.isAuthenticated ? Color.gray : Color.gray.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(!authViewModel.isAuthenticated)
                                
                                Button(action: {
                                    if authViewModel.isAuthenticated {
                                        Task {
                                            do {
                                                let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                                let rental = cartManager.prepareRental(userId: userId)
                                                try await rentalManager.saveRental(rental)
                                                cartManager.clearCart()
                                                showConfirmation = true
                                            } catch {
                                                errorMessage = "Failed to confirm booking: \(error.localizedDescription)"
                                                showError = true
                                            }
                                        }
                                    } else {
                                        showSignIn?.wrappedValue = true
                                    }
                                }) {
                                    Text("Confirm Booking")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .frame(maxWidth: .infinity, minHeight: 44) // Ensure touch target
                                        .background(authViewModel.isAuthenticated ? Color.blue : Color.gray.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(!authViewModel.isAuthenticated)
                            }
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                    }
                }
                .navigationTitle("Cart")
                .font(Typography.title) // Use Typography for consistent styling
                .alert("Rental Confirmed", isPresented: $showConfirmation) {
                    Button("OK") { dismiss() }
                } message: {
                    Text("Your rental has been successfully booked.")
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }

struct CartRow: View {
    let item: CartItem
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel // NEW: Access AuthenticationViewModel
    @Environment(\.showSignIn) var showSignIn // NEW: Access showSignIn binding
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var rentalDays: Int {
        Calendar.current.dateComponents([.day], from: item.pickupDate, to: item.returnDate).day ?? 1
    }
    
    private var totalCost: Double {
        Double(item.quantity) * item.tool.price * Double(rentalDays)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // Increased spacing
            HStack(alignment: .top, spacing: 12) {
                if let imageURL = item.tool.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        case .empty:
                            ProgressView()
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.5))
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        @unknown default:
                            Image(systemName: "exclamationmark.triangle")
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.tool.name)
//                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .font(Typography.headline) // Use Typography for consistent styling
                    Text(item.tool.description)
//                        .font(.system(size: 14, weight: .regular, design: .rounded)) // Increased font
                        .font(Typography.subheadline) // Use Typography for consistent styling
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text("Pickup: \(dateFormatter.string(from: item.pickupDate))")
                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Increased font
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    Text("Return: \(dateFormatter.string(from: item.returnDate))")
                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Increased font
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                HStack(spacing: 12) {
                    Text("Price: \(item.tool.price, specifier: "%.2f") SEK/day")
                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Increased font
                    Text("Total: \(totalCost, specifier: "%.2f") SEK (\(rentalDays) days)")
                        .font(Typography.headline) // Use Typography for consistent styling
//                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Increased font
                }
            }
            
            HStack {
                Text("Quantity:")
//                    .font(.system(size: 16, weight: .medium, design: .rounded)) // Increased font
                    .font(Typography.body) // Use Typography for consistent styling
                Stepper(value: Binding(
                    get: { item.quantity },
                    set: { newValue in
                        if authViewModel.isAuthenticated {
                            cartManager.updateQuantity(for: item.tool, quantity: newValue)
                        } else {
                            showSignIn?.wrappedValue = true
                        }
                    }
                ), in: 0...item.tool.numberOfItems) {
                    Text("\(item.quantity)")
                        .font(.system(size: 16, weight: .regular, design: .rounded)) // Increased font
                        .frame(minWidth: 20, alignment: .center)
                }
                .disabled(!authViewModel.isAuthenticated)
            }
            .padding(.top, 8)
        }
        .padding(16) // Increased padding
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
