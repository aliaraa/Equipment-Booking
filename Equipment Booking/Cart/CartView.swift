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
                            .font(.system(size: 18, weight: .medium, design: .rounded))
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
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
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
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
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
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text(item.tool.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded)) // Increased font
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
                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Increased font
                }
            }
            
            HStack {
                Text("Quantity:")
                    .font(.system(size: 16, weight: .medium, design: .rounded)) // Increased font
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



//struct CartView: View {
//    @EnvironmentObject var cartManager: CartManager
//    @EnvironmentObject var equipmentManager: EquipmentDataManager
//    @StateObject private var rentalManager = RentalManager.shared
//    @Environment(\.dismiss) var dismiss
//    @State private var showConfirmation = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if cartManager.cartItems.isEmpty {
//                    Text("Your cart is empty")
//                        .font(.system(size: 18, weight: .medium, design: .rounded))
//                        .foregroundColor(.gray)
//                        .frame(maxHeight: .infinity)
//                } else {
//                    List {
//                        ForEach(cartManager.cartItems) { item in
//                            CartRow(item: item)
//                        }
//                        .onDelete(perform: cartManager.removeFromCart)
//                    }
//                    .listStyle(.plain)
//                }
//                
//                if !cartManager.cartItems.isEmpty {
//                    VStack(spacing: 16) {
//                        // Total kostnad
//                        Text("Total: \(cartManager.totalCost(), specifier: "%.2f") SEK")
//                            .font(.system(size: 18, weight: .semibold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        HStack(spacing: 20) {
//                            // Clear Cart-knapp
//                            Button(action: {
//                                cartManager.clearCart()
//                                dismiss()
//                            }) {
//                                Text("Clear Cart")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .frame(height: 50)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.gray)
//                                    .cornerRadius(12)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                            
//                            // Confirm-knapp
//                            Button(action: {
//                                Task {
//                                    do {
//                                        let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
//                                        let rental = cartManager.prepareRental(userId: userId)
//                                        try await rentalManager.saveRental(rental)
//                                        cartManager.clearCart()
//                                        showConfirmation = true
//                                    } catch {
//                                        print("Error confirming rental: \(error)")
//                                    }
//                                }
//                            }) {
//                                Text("Confirm Booking")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .frame(height: 50)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue)
//                                    .cornerRadius(12)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(.systemGroupedBackground))
//                }
//            }
//            .navigationTitle("Cart")
//            .alert("Rental Confirmed", isPresented: $showConfirmation) {
//                Button("OK") { dismiss() }
//            } message: {
//                Text("Your rental has been successfully booked.")
//                    .font(.system(size: 16, weight: .regular, design: .rounded))
//            }
//        }
//    }
//}
//
//struct CartRow: View {
//    let item: CartItem
//    @EnvironmentObject var cartManager: CartManager
//    
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }
//    
//    private var rentalDays: Int {
//        Calendar.current.dateComponents([.day], from: item.pickupDate, to: item.returnDate).day ?? 1
//    }
//    
//    private var totalCost: Double {
//        Double(item.quantity) * item.tool.price * Double(rentalDays)
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Verktygsnamn och bild
//            HStack(alignment: .top, spacing: 12) {
//                if let imageURL = item.tool.imageURL, let url = URL(string: imageURL) {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(8)
//                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
//                        case .empty:
//                            ProgressView()
//                                .frame(width: 60, height: 60)
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                        case .failure:
//                            Image(systemName: "photo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.gray.opacity(0.5))
//                                .background(Color.gray.opacity(0.1))
//                                .cornerRadius(8)
//                        @unknown default:
//                            Image(systemName: "exclamationmark.triangle")
//                                .frame(width: 60, height: 60)
//                                .foregroundColor(.orange)
//                        }
//                    }
//                } else {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.gray.opacity(0.5))
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(item.tool.name)
//                        .font(.system(size: 16, weight: .semibold, design: .rounded))
//                        .foregroundColor(.primary)
//                        .lineLimit(2)
//                    
//                    Text(item.tool.description)
//                        .font(.system(size: 14, weight: .regular, design: .rounded))
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                        .truncationMode(.tail)
//                }
//            }
//            
//            // Bokningsdetaljer
//            VStack(alignment: .leading, spacing: 8) {
//                HStack(spacing: 12) {
//                    Text("Pickup: \(dateFormatter.string(from: item.pickupDate))")
//                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                        .foregroundColor(.blue)
//                        .padding(.vertical, 4)
//                        .padding(.horizontal, 8)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(6)
//                    
//                    Text("Return: \(dateFormatter.string(from: item.returnDate))")
//                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                        .foregroundColor(.blue)
//                        .padding(.vertical, 4)
//                        .padding(.horizontal, 8)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(6)
//                }
//                
//                HStack(spacing: 12) {
//                    Text("Price: \(item.tool.price, specifier: "%.2f") SEK/day")
//                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                        .foregroundColor(.primary)
//                    
//                    Text("Total: \(totalCost, specifier: "%.2f") SEK (\(rentalDays) days)")
//                        .font(.system(size: 13, weight: .medium, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//            }
//            
//            // Antal och stepper
//            HStack {
//                Text("Quantity:")
//                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                    .foregroundColor(.primary)
//                
//                Stepper(value: Binding(
//                    get: { item.quantity },
//                    set: { cartManager.updateQuantity(for: item.tool, quantity: $0) }
//                ), in: 0...item.tool.numberOfItems) {
//                    Text("\(item.quantity)")
//                        .font(.system(size: 14, weight: .regular, design: .rounded))
//                        .foregroundColor(.secondary)
//                        .frame(minWidth: 20, alignment: .center)
//                }
//            }
//            .padding(.top, 4)
//        }
//        .padding(12)
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
//    }
//}
//
//#Preview {
//    CartView()
//        .environmentObject(CartManager())
//        .environmentObject(EquipmentDataManager())
//}
//
