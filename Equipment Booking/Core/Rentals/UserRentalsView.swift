//
//  UserRentalsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/9/25.
//

// view to display rentals, handle returns, and show cart icon


// UserRentalsView.swift
import SwiftUI
import FirebaseFirestore

struct UserRentalsView: View {
    @EnvironmentObject var cartManager: CartManager
    @StateObject private var rentalManager = RentalManager.shared
    @StateObject private var equipmentManager = EquipmentDataManager()
    @State private var rentals: [Rental] = []
    @State private var showCartView = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // Filtrera aktiva och historiska hyror
    private var activeRentals: [Rental] {
        rentals.filter { $0.status.lowercased() == "active" }
    }
    
    private var rentalHistory: [Rental] {
        rentals.filter { $0.status.lowercased() != "active" }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Aktiva hyror
                    rentalsSection(
                        title: "Active Rentals",
                        rentals: activeRentals,
                        emptyMessage: "You have no active rentals."
                    )
                    
                    // Historik
                    rentalsSection(
                        title: "Rental History",
                        rentals: rentalHistory,
                        emptyMessage: "You have no rental history yet."
                    )
                }
                .padding(.horizontal)
            }
            .navigationTitle("My Rentals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCartView.toggle() }) {
                        Image(systemName: "cart")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(cartManager.cartItems.isEmpty ? .gray : .blue)
                            .overlay(
                                cartManager.cartItems.isEmpty ? nil :
                                    Text("\(cartManager.cartItems.count)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10),
                                alignment: .topTrailing
                            )
                    }
                }
            }
            .sheet(isPresented: $showCartView) {
                CartView()
            }
            .task {
                do {
                    let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                    rentals = try await rentalManager.fetchUserRentals(userId: userId)
                } catch {
                    print("Error fetching rentals: \(error)")
                }
            }
        }
    }
    
    @ViewBuilder
    private func rentalsSection(title: String, rentals: [Rental], emptyMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            if rentals.isEmpty {
                Text(emptyMessage)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                ForEach(rentals) { rental in
                    RentalRow(rental: rental, equipmentManager: equipmentManager) { rentalId, items in
                        Task {
                            do {
                                try await rentalManager.returnRental(rentalId: rentalId, items: items)
                                let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                self.rentals = try await rentalManager.fetchUserRentals(userId: userId)
                            } catch {
                                print("Error returning rental: \(error)")
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }
}

struct RentalRow: View {
    let rental: Rental
    let equipmentManager: EquipmentDataManager
    let onReturn: (String, [RentalItem]) -> Void
    
    @State private var showReturnConfirmation = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func rentalDays(for pickupDate: Date, returnDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: pickupDate, to: returnDate).day ?? 1
    }
    
    private func totalCost(for item: RentalItem, pickupDate: Date, returnDate: Date) -> Double {
        guard let tool = equipmentManager.toolData.first(where: { $0.id == item.id }) else { return 0.0 }
        let days = rentalDays(for: pickupDate, returnDate: returnDate)
        return Double(item.quantity) * tool.price * Double(days)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(rental.items) { item in
                if let tool = equipmentManager.toolData.first(where: { $0.id == item.id }) {
                    HStack(alignment: .top, spacing: 12) {
                        // Bild
                        if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
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
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray.opacity(0.5))
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Info om verktyget
                        VStack(alignment: .leading, spacing: 8) {
                            // Namn och returknapp
                            HStack {
                                Text(tool.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                if rental.status.lowercased() == "active" {
                                    Button(action: {
                                        showReturnConfirmation = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "return")
                                            Text("Return")
                                        }
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.blue)
                                        .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            // Status och beskrivning
                            HStack {
                                Text(rental.status.capitalized)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(rental.status.lowercased() == "active" ? .green : .gray)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 6)
                                    .background((rental.status.lowercased() == "active" ? Color.green : Color.gray).opacity(0.1))
                                    .cornerRadius(4)
                                
                                Text(tool.description)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            // Datum och kostnad
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 12) {
                                    Text("Pickup: \(dateFormatter.string(from: rental.pickupDate))")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.blue)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                    
                                    Text("Due: \(dateFormatter.string(from: rental.returnDate))")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(isOverdue(rental.returnDate) ? .red : .blue)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background((isOverdue(rental.returnDate) ? Color.red : Color.blue).opacity(0.1))
                                        .cornerRadius(6)
                                }
                                
                                HStack(spacing: 12) {
                                    Text("Qty: \(item.quantity)")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text("Total: \(totalCost(for: item, pickupDate: rental.pickupDate, returnDate: rental.returnDate), specifier: "%.2f") SEK")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            // Överlämnad-info
                            if isOverdue(rental.returnDate) {
                                Text("Overdue by \(daysOverdue(rental.returnDate)) days")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
        .alert("Confirm Return", isPresented: $showReturnConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Return") {
                onReturn(rental.id, rental.items)
            }
        } message: {
            Text("Are you sure you want to return this rental?")
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
    }
    
    private func isOverdue(_ returnDate: Date) -> Bool {
        return returnDate < Date()
    }
    
    private func daysOverdue(_ returnDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: returnDate, to: Date())
        return components.day ?? 0
    }
}

#Preview {
    UserRentalsView()
        .environmentObject(CartManager())
}
