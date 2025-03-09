//
//  UserRentalsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/9/25.
//

// view to display rentals, handle returns, and show cart icon


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
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack {
                rentalsContent
                Spacer()
            }
            .navigationTitle("My Rentals")
            .toolbar {
                // Cart icon moved to top-left
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCartView.toggle() }) {
                        Image(systemName: "cart")
                            .font(.title2)
                            .foregroundColor(cartManager.cartItems.isEmpty ? .gray : .blue)
                            .overlay(
                                cartManager.cartItems.isEmpty ? nil :
                                    Text("\(cartManager.cartItems.count)")
                                        .font(.caption2)
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
    
    private var rentalsContent: some View {
        if rentals.isEmpty {
            return AnyView(
                Text("You have no active rentals.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            )
        } else {
            return AnyView(
                List(rentals) { rental in
                    RentalRow(rental: rental, equipmentManager: equipmentManager) { rentalId, items in
                        Task {
                            do {
                                try await rentalManager.returnRental(rentalId: rentalId, items: items)
                                let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                rentals = try await rentalManager.fetchUserRentals(userId: userId)
                            } catch {
                                print("Error returning rental: \(error)")
                            }
                        }
                    }
                }
            )
        }
    }
}

struct RentalRow: View {
    let rental: Rental
    let equipmentManager: EquipmentDataManager
    let onReturn: (String, [RentalItem]) -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rental.items) { item in
                if let equipment = equipmentManager.toolData.first(where: { $0.id == item.id }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(equipment.name)
                                .font(.headline)
                            dueDateView(returnDate: rental.returnDate)
                        }
                        Spacer()
                        returnButton(rental: rental)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func dueDateView(returnDate: Date) -> some View {
        VStack(alignment: .leading) {
            Text("Due: \(dateFormatter.string(from: returnDate))")
                .font(.subheadline)
                .foregroundColor(isOverdue(returnDate) ? .red : .gray)
            if isOverdue(returnDate) {
                Text("Overdue by \(daysOverdue(returnDate)) days")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private func returnButton(rental: Rental) -> some View {
        if rental.status == "active" {
            Button(action: {
                onReturn(rental.id, rental.items)
            }) {
                Image(systemName: "return")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
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
