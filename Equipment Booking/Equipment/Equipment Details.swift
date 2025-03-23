//
//  Equipment Details.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

// Dismiss view on "Add to Cart" and ensure cart updates

// Equipment_Details.swift
import SwiftUI

struct Equipment_Details: View {
    var tool: Tool
    @EnvironmentObject var cartManager: CartManager
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
                print("No return date selected, available set to total: \(availableQuantity)")
                return
            }
            do {
                print("Fetching availability for \(tool.id) from \(dateFormatter.string(from: selectPickupDate)) to \(dateFormatter.string(from: returnDate))")
                let (_, available) = try await equipmentManager.getToolAvailability(
                    forToolId: tool.id,
                    pickupDate: selectPickupDate,
                    returnDate: returnDate
                )
                availableQuantity = available
                print("Updated availability for \(tool.id): \(availableQuantity)")
            } catch {
                print("Error fetching availability: \(error)")
                availableQuantity = totalQuantity
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Verktygsnamn
                    Text(tool.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                    
                    // Bild
                    if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.gray.opacity(0.5))
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            @unknown default:
                                Image(systemName: "exclamationmark.triangle")
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.orange)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Beskrivning
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Description")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(tool.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(showMore ? nil : 2)
                            .animation(.easeInOut, value: showMore)
                        
                        Button(action: { showMore.toggle() }) {
                            Text(showMore ? "Visa mindre" : "Visa mer")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Tillgänglighet
                    VStack(alignment: .leading, spacing: 10) {
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Antal
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quantity")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus")
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            Text("\(quantity)")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .center)
                            Button(action: { if quantity < availableQuantity { quantity += 1 } }) {
                                Image(systemName: "plus")
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Datumval
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Booking Dates")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Button("Pickup Date") {
                                isPickingDate = true
                                isShowingDatePicker.toggle()
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            Spacer()
                            Text(dateFormatter.string(from: selectPickupDate))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            Button("Return Date") {
                                isPickingDate = false
                                isShowingDatePicker.toggle()
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Add to Cart-knapp
                    Button(action: {
                        if let returnDate = selectReturnDate {
                            cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: returnDate)
                            showConfirmation = true
                        }
                    }) {
                        Text("Add to Cart")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isAddToCartEnabled ? Color.green : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .disabled(!isAddToCartEnabled)
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
                                VStack {
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
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                                    
                                    Button("Done") {
                                        handleDateSelection(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
                                    }
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
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
            }
            .task {
                do {
                    nextAvailableDate = try await equipmentManager.getNextAvailableDate(forToolId: tool.id)
                    selectPickupDate = nextAvailableDate
                    selectReturnDate = Calendar.current.date(byAdding: .day, value: 7, to: selectPickupDate) ?? selectPickupDate
                    let (_, available) = try await equipmentManager.getToolAvailability(
                        forToolId: tool.id,
                        pickupDate: selectPickupDate,
                        returnDate: selectReturnDate!
                    )
                    availableQuantity = available
                    print("Initial setup: pickup = \(dateFormatter.string(from: selectPickupDate)), return = \(dateFormatter.string(from: selectReturnDate!)), available = \(availableQuantity)")
                } catch {
                    print("Error initializing: \(error)")
                    availableQuantity = totalQuantity
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
    numberOfItems: 1,
    isAvailable: true
)

#Preview {
    Equipment_Details(tool: exampleTool)
        .environmentObject(CartManager())
}
