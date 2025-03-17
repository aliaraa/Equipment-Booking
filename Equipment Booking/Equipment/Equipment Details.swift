//
//  Equipment Details.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

// Dismiss view on "Add to Cart" and ensure cart updates

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
    
    // Date formatter for display
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    // Enable "Add to Cart" only if dates are valid and quantity is available
    var isAddToCartEnabled: Bool {
        if let returnDate = selectReturnDate {
            return selectPickupDate >= nextAvailableDate && selectPickupDate < returnDate && quantity <= tool.numberOfItems
        }
        return false
    }
    
    // Handle date selection logic
    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = max(date, nextAvailableDate)
            if let returnDate = selectReturnDate, returnDate < selectPickupDate {
                selectReturnDate = selectPickupDate
            }
        } else {
            selectReturnDate = date
            if selectPickupDate > date {
                selectPickupDate = date
            }
        }
        isShowingDatePicker = false
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Titel
                    Text(tool.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    // Bild
                    if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.gray.opacity(0.5))
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            @unknown default:
                                Image(systemName: "exclamationmark.triangle")
                                    .frame(maxWidth: .infinity, maxHeight: 250)
                                    .foregroundColor(.orange)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        Image(systemName: "hammer.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .foregroundColor(.gray.opacity(0.5))
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Beskrivning och pris
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(tool.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                        
                        Text("Price per day: \(tool.price) SEK")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    // Kvantitet
                    HStack(spacing: 20) {
                        Text("Quantity")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus")
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .background(Color.blue.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            Text("\(quantity)")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .frame(width: 50)
                                .foregroundColor(.primary)
                            Button(action: { if quantity < tool.numberOfItems { quantity += 1 } }) {
                                Image(systemName: "plus")
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .background(Color.blue.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 6)
                    
                    // Datumval
                    VStack(spacing: 12) {
                        HStack {
                            Button("Pickup Date") {
                                isPickingDate = true
                                isShowingDatePicker.toggle()
                            }
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            Spacer()
                            Text(dateFormatter.string(from: selectPickupDate))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Button("Return Date") {
                                isPickingDate = false
                                isShowingDatePicker.toggle()
                            }
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            Spacer()
                            if let returnDate = selectReturnDate {
                                Text(dateFormatter.string(from: returnDate))
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Select Date")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .italic()
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 6)
                    
                    // Add to Cart-knapp
                    Button(action: {
                        if let returnDate = selectReturnDate {
                            cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: returnDate)
                            showConfirmation = true
                        }
                    }) {
                        Text("Add to Cart")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(width: 200, height: 50)
                            .background(isAddToCartEnabled ? Color.green.opacity(0.9) : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                            .shadow(radius: isAddToCartEnabled ? 4 : 0)
                    }
                    .disabled(!isAddToCartEnabled)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Equipment Details") // Explicit String
            .navigationBarTitleDisplayMode(.inline) // För tydligare placering
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
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.blue.opacity(0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(20)
                            )
                    }
                }
            )
            .alert("Added to Cart", isPresented: $showConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(quantity) x \(tool.name) added to your cart.")
            }
            .task {
                do {
                    nextAvailableDate = try await
                    equipmentManager.getNextAvailableDate(forToolId: tool.id)
                    selectPickupDate = nextAvailableDate // Sätt initialt pickup-datum till nästa tillgängliga
                } catch {
                    print("Error fetching next available date: \(error)")
                }
            }
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

