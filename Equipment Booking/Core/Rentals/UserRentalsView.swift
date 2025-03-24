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
    @State private var isHistoryExpanded = false
    @State private var showDateFilterSheet = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var activeRentals: [Rental] {
        rentals.filter { $0.status.lowercased() == "active" }
    }
    
    private var rentalHistory: [Rental] {
        rentals.filter { $0.status.lowercased() != "active" }
            .filter { $0.returnDate >= startDate && $0.returnDate <= endDate }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    rentalsSection(
                        title: "Active Rentals",
                        rentals: activeRentals,
                        emptyMessage: "You have no active rentals."
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rental History")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: { withAnimation { isHistoryExpanded.toggle() } }) {
                                Image(systemName: isHistoryExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 8)
                        
                        if isHistoryExpanded {
                            Button(action: { showDateFilterSheet = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                    Text("Filter by Date")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                            }
                            .padding(.vertical, 8)
                            
                            Text("Showing rentals from \(dateFormatter.string(from: startDate)) to \(dateFormatter.string(from: endDate))")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.bottom, 4)
                            
                            if rentalHistory.isEmpty {
                                Text("No rentals found for this period.")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(rentalHistory) { rental in
                                    RentalRow(rental: rental, equipmentManager: equipmentManager) { rentalId, items in
                                        Task {
                                            do {
                                                try await rentalManager.returnRental(rentalId: rentalId, items: items)
                                                let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                                rentals = try await rentalManager.fetchUserRentals(userId: userId)
                                                print("Updated rentals after return: \(rentals.map { "\($0.id): \($0.status)" }.joined(separator: ", "))")
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
            .sheet(isPresented: $showDateFilterSheet) {
                // Förbättrad sheet med rullande hjul
                VStack(spacing: 20) {
                    // Rubrik och stängningsknapp
                    HStack {
                        Text("Filter Rental History")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: { showDateFilterSheet = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Startdatum
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Date: \(dateFormatter.string(from: startDate))")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 120) // Minskad höjd på hjulen
                            .clipped() // Förhindrar att hjulen går utanför ramen
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Slutdatum
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Date: \(dateFormatter.string(from: endDate))")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 120) // Minskad höjd på hjulen
                            .clipped()
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Knappar
                    HStack(spacing: 16) {
                        Button(action: { showDateFilterSheet = false }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showDateFilterSheet = false }) {
                            Text("Apply Filter")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showCartView) {
                CartView()
            }
            .task {
                do {
                    let userId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                    rentals = try await rentalManager.fetchUserRentals(userId: userId)
                    print("Fetched \(rentals.count) rentals: \(rentals.map { "\($0.id): \($0.status)" }.joined(separator: ", "))")
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
                                print("Updated rentals after return: \(rentals.map { "\($0.id): \($0.status)" }.joined(separator: ", "))")
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
                        
                        VStack(alignment: .leading, spacing: 8) {
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
