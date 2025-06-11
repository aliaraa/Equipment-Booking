// Equipment_Details.swift
// Equipment Booking
//
// Created by Ali Ara on 2025-01-05.

import SwiftUI

struct Equipment_Details: View {
    var tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.showSignIn) var showSignIn
    @Environment(\.dismiss) var dismiss
    @StateObject private var equipmentManager = EquipmentManager.shared
    @State private var selectPickupDate: Date = Date()
    @State private var selectReturnDate: Date? = nil
    @State private var isShowingDatePicker = false
    @State private var isPickingDate = true
    @State private var quantity: Int = 1
    @State private var showConfirmation = false
    @State private var nextAvailableDate: Date = Date()
    @State private var totalQuantity: Int
    @State private var availableQuantity: Int = 0
    @State private var showMore = false
    @State private var availabilityMessage: String = ""
    
    init(tool: Tool) {
        self.tool = tool
        self._totalQuantity = State(initialValue: tool.numberOfItems)
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var isAddToCartEnabled: Bool {
        if let returnDate = selectReturnDate {
            return selectPickupDate >= nextAvailableDate && selectPickupDate < returnDate && quantity <= availableQuantity && quantity > 0
        }
        return false
    }
    
    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = max(date, nextAvailableDate)
            if let returnDate = selectReturnDate, returnDate <= selectPickupDate {
                selectReturnDate = Calendar.current.date(byAdding: .day, value: 1, to: selectPickupDate)
            }
        } else {
            selectReturnDate = max(date, Calendar.current.date(byAdding: .day, value: 1, to: selectPickupDate) ?? date)
            if selectPickupDate >= date {
                selectPickupDate = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
            }
        }
        isShowingDatePicker = false
        updateAvailability()
    }
    
    private func updateAvailability() {
        Task {
            guard let returnDate = selectReturnDate else {
                availableQuantity = totalQuantity
                availabilityMessage = "Select a return date to check availability."
                return
            }
            
            do {
                let (bookings, available) = try await equipmentManager.getToolAvailability(
                    forToolId: tool.id,
                    pickupDate: selectPickupDate,
                    returnDate: returnDate
                )
                availableQuantity = available
                
                if available == totalQuantity {
                    availabilityMessage = ""
                } else {
                    availabilityMessage = "Limited availability:"
                    for booking in bookings {
                        let start = dateFormatter.string(from: booking.pickupDate)
                        let end = dateFormatter.string(from: booking.returnDate)
                        if let item = booking.items.first(where: { $0.id == tool.id }) {
                            availabilityMessage += "\n- \(item.quantity) booked from \(start) to \(end)"
                        }
                    }
                }
            } catch {
                print("Error fetching availability: \(error)")
                availableQuantity = totalQuantity
                availabilityMessage = "Error fetching availability."
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text(tool.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                    
                    if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .cornerRadius(12)
                                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.gray.opacity(0.5))
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
                            @unknown default:
                                Image(systemName: "exclamationmark.triangle")
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.orange)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(tool.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(showMore ? nil : 2)
                            .animation(.easeInOut(duration: 0.3), value: showMore)
                        
                        Button(action: { showMore.toggle() }) {
                            Text(showMore ? "Show less" : "Show more")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color.accentColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Availability")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text("Total:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Text("\(totalQuantity)")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Text("Available:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            Text("\(availableQuantity)")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(availableQuantity > 0 ? .green : .red)
                            Spacer()
                            Image(systemName: availableQuantity > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(availableQuantity > 0 ? .green : .red)
                        }
                        
                        if !availabilityMessage.isEmpty {
                            Text(availabilityMessage)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.accentColor)
                                    .cornerRadius(20)
                                    .shadow(color: .gray.opacity(0.2), radius: 2)
                            }
                            Text("\(quantity)")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(width: 50, alignment: .center)
                            Button(action: { if quantity < availableQuantity { quantity += 1 } }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color.accentColor)
                                    .cornerRadius(20)
                                    .shadow(color: .gray.opacity(0.2), radius: 2)
                            }
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Booking Dates")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                isPickingDate = true
                                isShowingDatePicker.toggle()
                            }) {
                                Text("Pickup Date")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color.accentColor)
                                    .cornerRadius(8)
                                    .shadow(color: .gray.opacity(0.2), radius: 2)
                            }
                            Spacer()
                            Text(dateFormatter.string(from: selectPickupDate))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                isPickingDate = false
                                isShowingDatePicker.toggle()
                            }) {
                                Text("Return Date")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color.accentColor)
                                    .cornerRadius(8)
                                    .shadow(color: .gray.opacity(0.2), radius: 2)
                            }
                            Spacer()
                            if let returnDate = selectReturnDate {
                                Text(dateFormatter.string(from: returnDate))
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Select Date")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .italic()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    
                    Button(action: {
                        if authViewModel.isAuthenticated {
                            if let returnDate = selectReturnDate {
                                cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: returnDate)
                                showConfirmation = true
                            }
                        } else {
                            showSignIn?.wrappedValue = true
                        }
                    }) {
                        Text(authViewModel.isAuthenticated ? "Add to Cart" : "Sign In to Add to Cart")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isAddToCartEnabled && authViewModel.isAuthenticated ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(isAddToCartEnabled && authViewModel.isAuthenticated ? 0.3 : 0), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Equipment Details")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Group {
                    if isShowingDatePicker {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .overlay(
                                VStack(spacing: 12) {
                                    DatePicker(
                                        "Select Date",
                                        selection: isPickingDate ? $selectPickupDate : Binding(
                                            get: { selectReturnDate ?? Date() },
                                            set: { selectReturnDate = $0 }
                                        ),
                                        in: nextAvailableDate...,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: .gray.opacity(0.2), radius: 8)
                                    
                                    Button(action: {
                                        handleDateSelection(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
                                    }) {
                                        Text("Done")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(Color.accentColor)
                                            .cornerRadius(8)
                                            .shadow(color: .gray.opacity(0.2), radius: 2)
                                    }
                                }
                                .padding(20)
                            )
                    }
                }
            )
            .alert("Added to Cart", isPresented: $showConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(quantity) x \(tool.name) added to your cart.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
            }
            .task {
                do {
                    nextAvailableDate = try await equipmentManager.getNextAvailableDate(forToolId: tool.id)
                    selectPickupDate = nextAvailableDate
                    selectReturnDate = Calendar.current.date(byAdding: .day, value: 7, to: selectPickupDate) ?? selectPickupDate
                    updateAvailability()
                } catch {
                    print("Error initializing: \(error)")
                    availableQuantity = totalQuantity
                    availabilityMessage = "Error initializing availability."
                }
            }
            .onChange(of: selectPickupDate) { _ in updateAvailability() }
            .onChange(of: selectReturnDate) { _ in updateAvailability() }
        }
    }
}

let exampleTool = Tool(
    id: "LCE-CM-11",
    name: "Petrol-powered mobile cutters, plates 400-500mm",
    category: "Construction",
    mainCategory: "Light construction equipment",
    subCategory: "Cutting machines",
    description: "The mobile petrol cutter with a 500 mm blade is used for cutting asphalt or concrete surfaces using diamond blades.",
    manufacturer: "Ntc",
    imageName: "B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
    imageURL: "https://storage.googleapis.com/equipment-management-db.firebasestorage.app/Equipment_imgs/B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
    status: "available",
    price: 100.0,
    numberOfItems: 4,
    isAvailable: true
)

struct Equipment_Details_Previews: PreviewProvider {
    static var previews: some View {
        Equipment_Details(tool: exampleTool)
            .environmentObject(CartManager())
            .environmentObject(AuthenticationViewModel())
    }
}


// inactivate add to cart button
//struct Equipment_Details: View {
//    var tool: Tool
//    @EnvironmentObject var cartManager: CartManager
//    @EnvironmentObject var authViewModel: AuthenticationViewModel // NEW: For authentication checks
//    @Environment(\.showSignIn) var showSignIn // NEW: For sign-in sheet
//    @Environment(\.dismiss) var dismiss
//    @StateObject private var equipmentManager = EquipmentManager.shared
//    @State private var selectPickupDate: Date = Date()
//    @State private var selectReturnDate: Date? = nil
//    @State private var isShowingDatePicker = false
//    @State private var isPickingDate = true
//    @State private var quantity: Int = 1
//    @State private var showConfirmation = false
//    @State private var nextAvailableDate: Date = Date()
//    @State private var totalQuantity: Int
//    @State private var availableQuantity: Int = 0
//    @State private var showMore = false
//    @State private var availabilityMessage: String = ""
//    @State private var showSignInAlert: Bool = false // NEW: For sign-in alert
//    
//    init(tool: Tool) {
//        self.tool = tool
//        self._totalQuantity = State(initialValue: tool.numberOfItems)
//    }
//    
//    var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }
//    
//    var isAddToCartEnabled: Bool {
//        if let returnDate = selectReturnDate {
//            return selectPickupDate >= nextAvailableDate && selectPickupDate < returnDate && quantity <= availableQuantity && quantity > 0
//        }
//        return false
//    }
//    
//    func handleDateSelection(_ date: Date) {
//        if isPickingDate {
//            selectPickupDate = max(date, nextAvailableDate)
//            if let returnDate = selectReturnDate, returnDate <= selectPickupDate {
//                selectReturnDate = Calendar.current.date(byAdding: .day, value: 1, to: selectPickupDate)
//            }
//        } else {
//            selectReturnDate = max(date, Calendar.current.date(byAdding: .day, value: 1, to: selectPickupDate) ?? date)
//            if selectPickupDate >= date {
//                selectPickupDate = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
//            }
//        }
//        isShowingDatePicker = false
//        updateAvailability()
//    }
//    
//    private func updateAvailability() {
//        Task {
//            guard let returnDate = selectReturnDate else {
//                availableQuantity = totalQuantity
//                availabilityMessage = "Select a return date to check availability."
//                return
//            }
//            
//            do {
//                let (bookings, available) = try await equipmentManager.getToolAvailability(
//                    forToolId: tool.id,
//                    pickupDate: selectPickupDate,
//                    returnDate: returnDate
//                )
//                availableQuantity = available
//                
//                if available == totalQuantity {
//                    availabilityMessage = ""
//                } else {
//                    availabilityMessage = "Limited availability:"
//                    for booking in bookings {
//                        let start = dateFormatter.string(from: booking.pickupDate)
//                        let end = dateFormatter.string(from: booking.returnDate)
//                        if let item = booking.items.first(where: { $0.id == tool.id }) {
//                            availabilityMessage += "\n- \(item.quantity) booked from \(start) to \(end)"
//                        }
//                    }
//                }
//            } catch {
//                print("Error fetching availability: \(error)")
//                availableQuantity = totalQuantity
//                availabilityMessage = "Error fetching availability."
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//                    Text(tool.name)
//                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                        .foregroundColor(.primary)
//                        .padding(.top, 20)
//                        .padding(.horizontal, 16)
//                    
//                    if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
//                        AsyncImage(url: url) { phase in
//                            switch phase {
//                            case .empty:
//                                ProgressView()
//                                    .frame(maxWidth: .infinity, maxHeight: 250)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(12)
//                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity, maxHeight: 250)
//                                    .cornerRadius(12)
//                                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
//                            case .failure:
//                                Image(systemName: "photo")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity, maxHeight: 250)
//                                    .foregroundColor(.gray.opacity(0.5))
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(12)
//                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
//                            @unknown default:
//                                Image(systemName: "exclamationmark.triangle")
//                                    .frame(maxWidth: .infinity, maxHeight: 250)
//                                    .foregroundColor(.orange)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(12)
//                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Description")
//                            .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        Text(tool.description)
//                            .font(.system(size: 16, weight: .regular, design: .rounded))
//                            .foregroundColor(.secondary)
//                            .lineLimit(showMore ? nil : 2)
//                            .animation(.easeInOut(duration: 0.3), value: showMore)
//                        
//                        Button(action: { showMore.toggle() }) {
//                            Text(showMore ? "Show less" : "Show more")
//                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                .foregroundColor(Color.accentColor)
//                                .padding(.vertical, 4)
//                                .padding(.horizontal, 8)
//                                .background(Color.accentColor.opacity(0.1))
//                                .cornerRadius(6)
//                        }
//                    }
//                    .padding(16)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
//                    .padding(.horizontal, 16)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Availability")
//                            .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        HStack(spacing: 8) {
//                            Text("Total:")
//                                .font(.system(size: 16, weight: .medium, design: .rounded))
//                                .foregroundColor(.primary)
//                            Text("\(totalQuantity)")
//                                .font(.system(size: 16, weight: .regular, design: .rounded))
//                                .foregroundColor(.secondary)
//                            Spacer()
//                        }
//                        
//                        HStack(spacing: 8) {
//                            Text("Available:")
//                                .font(.system(size: 16, weight: .medium, design: .rounded))
//                                .foregroundColor(.primary)
//                            Text("\(availableQuantity)")
//                                .font(.system(size: 16, weight: .regular, design: .rounded))
//                                .foregroundColor(availableQuantity > 0 ? .green : .red)
//                            Spacer()
//                            Image(systemName: availableQuantity > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
//                                .foregroundColor(availableQuantity > 0 ? .green : .red)
//                        }
//                        
//                        if !availabilityMessage.isEmpty {
//                            Text(availabilityMessage)
//                                .font(.system(size: 14, weight: .regular, design: .rounded))
//                                .foregroundColor(.secondary)
//                                .lineLimit(nil)
//                        }
//                    }
//                    .padding(16)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
//                    .padding(.horizontal, 16)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Quantity")
//                            .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        HStack(spacing: 16) {
//                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
//                                Image(systemName: "minus")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .frame(width: 40, height: 40)
//                                    .foregroundColor(.white)
//                                    .background(Color.accentColor)
//                                    .cornerRadius(20)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                            Text("\(quantity)")
//                                .font(.system(size: 18, weight: .semibold, design: .rounded))
//                                .foregroundColor(.primary)
//                                .frame(width: 50, alignment: .center)
//                            Button(action: { if quantity < availableQuantity { quantity += 1 } }) {
//                                Image(systemName: "plus")
//                                    .font(.system(size: 16, weight: .medium))
//                                    .frame(width: 40, height: 40)
//                                    .foregroundColor(.white)
//                                    .background(Color.accentColor)
//                                    .cornerRadius(20)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                            Spacer()
//                        }
//                    }
//                    .padding(16)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
//                    .padding(.horizontal, 16)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Booking Dates")
//                            .font(.system(size: 20, weight: .semibold, design: .rounded))
//                            .foregroundColor(.primary)
//                        
//                        HStack(spacing: 8) {
//                            Button(action: {
//                                isPickingDate = true
//                                isShowingDatePicker.toggle()
//                            }) {
//                                Text("Pickup Date")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 10)
//                                    .padding(.horizontal, 16)
//                                    .background(Color.accentColor)
//                                    .cornerRadius(8)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                            Spacer()
//                            Text(dateFormatter.string(from: selectPickupDate))
//                                .font(.system(size: 16, weight: .regular, design: .rounded))
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack(spacing: 8) {
//                            Button(action: {
//                                isPickingDate = false
//                                isShowingDatePicker.toggle()
//                            }) {
//                                Text("Return Date")
//                                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 10)
//                                    .padding(.horizontal, 16)
//                                    .background(Color.accentColor)
//                                    .cornerRadius(8)
//                                    .shadow(color: .gray.opacity(0.2), radius: 2)
//                            }
//                            Spacer()
//                            if let returnDate = selectReturnDate {
//                                Text(dateFormatter.string(from: returnDate))
//                                    .font(.system(size: 16, weight: .regular, design: .rounded))
//                                    .foregroundColor(.secondary)
//                            } else {
//                                Text("Select Date")
//                                    .font(.system(size: 16, weight: .regular, design: .rounded))
//                                    .foregroundColor(.secondary.opacity(0.6))
//                                    .italic()
//                            }
//                        }
//                    }
//                    .padding(16)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
//                    .padding(.horizontal, 16)
//                    
//                    Button(action: {
//                        // NEW: Check authentication before adding to cart
//                        if authViewModel.isAuthenticated {
//                            if let returnDate = selectReturnDate {
//                                cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: returnDate)
//                                showConfirmation = true
//                            }
//                        } else {
//                            showSignInAlert = true
//                        }
//                    }) {
//                        // NEW: Dynamic button text for better UX
//                        Text(authViewModel.isAuthenticated ? "Add to Cart" : "Sign In to Add to Cart")
//                            .font(.system(size: 18, weight: .semibold, design: .rounded))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 14)
//                            .background(isAddToCartEnabled && authViewModel.isAuthenticated ? Color.green : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                            .shadow(color: .gray.opacity(isAddToCartEnabled && authViewModel.isAuthenticated ? 0.3 : 0), radius: 4, x: 0, y: 2)
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 20)
//                    .disabled(!isAddToCartEnabled)
//                    // NEW: Alert for unauthenticated users
//                    .alert("Sign In Required", isPresented: $showSignInAlert) {
//                        Button("Sign In") {
//                            showSignIn?.wrappedValue = true
//                        }
//                        Button("Cancel", role: .cancel) {
//                            showSignInAlert = false
//                        }
//                    } message: {
//                        Text("You need to sign in or register to add items to your cart.")
//                    }
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("Equipment Details")
//            .navigationBarTitleDisplayMode(.inline)
//            .overlay(
//                Group {
//                    if isShowingDatePicker {
//                        Color.black.opacity(0.5)
//                            .ignoresSafeArea()
//                            .overlay(
//                                VStack(spacing: 12) {
//                                    DatePicker(
//                                        "Select Date",
//                                        selection: isPickingDate ? $selectPickupDate : Binding(
//                                            get: { selectReturnDate ?? Date() },
//                                            set: { selectReturnDate = $0 }
//                                        ),
//                                        in: nextAvailableDate...,
//                                        displayedComponents: .date
//                                    )
//                                    .datePickerStyle(GraphicalDatePickerStyle())
//                                    .padding()
//                                    .background(Color(.systemBackground))
//                                    .cornerRadius(12)
//                                    .shadow(color: .gray.opacity(0.2), radius: 8)
//                                    
//                                    Button(action: {
//                                        handleDateSelection(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
//                                    }) {
//                                        Text("Done")
//                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                            .foregroundColor(.white)
//                                            .padding(.vertical, 10)
//                                            .padding(.horizontal, 20)
//                                            .background(Color.accentColor)
//                                            .cornerRadius(8)
//                                            .shadow(color: .gray.opacity(0.2), radius: 2)
//                                    }
//                                }
//                                .padding(20)
//                            )
//                    }
//                }
//            )
//            .alert("Added to Cart", isPresented: $showConfirmation) {
//                Button("OK") { dismiss() }
//            } message: {
//                Text("\(quantity) x \(tool.name) added to your cart.")
//                    .font(.system(size: 16, weight: .regular, design: .rounded))
//            }
//            .task {
//                do {
//                    nextAvailableDate = try await equipmentManager.getNextAvailableDate(forToolId: tool.id)
//                    selectPickupDate = nextAvailableDate
//                    selectReturnDate = Calendar.current.date(byAdding: .day, value: 7, to: selectPickupDate) ?? selectPickupDate
//                    updateAvailability()
//                } catch {
//                    print("Error initializing: \(error)")
//                    availableQuantity = totalQuantity
//                    availabilityMessage = "Error initializing availability."
//                }
//            }
//            .onChange(of: selectPickupDate) { _ in updateAvailability() }
//            .onChange(of: selectReturnDate) { _ in updateAvailability() }
//        }
//    }
//}
//
//let exampleTool = Tool(
//    id: "LCE-CM-11",
//    name: "Petrol-powered mobile cutters, plates 400-500mm",
//    category: "Construction",
//    mainCategory: "Light construction equipment",
//    subCategory: "Cutting machines",
//    description: "The mobile petrol cutter with a 500 mm blade is used for cutting asphalt or concrete surfaces using diamond blades.",
//    manufacturer: "Ntc",
//    imageName: "B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
//    imageURL: "https://storage.googleapis.com/equipment-management-db.firebasestorage.app/Equipment_imgs/B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
//    status: "available",
//    price: 100.0,
//    numberOfItems: 4,
//    isAvailable: true
//)
//
//
//struct Equipment_Details_Previews: PreviewProvider {
//    static var previews: some View {
//        Equipment_Details(tool: exampleTool)
//            .environmentObject(CartManager())
//            .environmentObject(AuthenticationViewModel()) // NEW: Add for auth checks
//    }
//}
