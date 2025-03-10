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
    @State private var selectPickupDate: Date = Date()
    @State private var selectReturnDate: Date? = nil
    @State private var isShowingDatePicker = false
    @State private var isPickingDate = true
    @State private var quantity: Int = 1
    @State private var showConfirmation = false
    
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
            return selectPickupDate < returnDate && quantity <= tool.numberOfItems
        }
        return false
    }
    
    // Handle date selection logic
    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
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
            ZStack {
                VStack {
                    Text(tool.name)
                        .font(.largeTitle)
                        .padding()
                    
                    if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 400.0, height: 300.0)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 400.0, height: 300.0)
                                    .background(Color.black)
                            case .failure:
                                Image(systemName: "photo")
                                    .frame(width: 400.0, height: 300.0)
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                                    .background(Color.black)
                            @unknown default:
                                Image(systemName: "exclamationmark.triangle")
                                    .frame(width: 400.0, height: 300.0)
                                    .imageScale(.large)
                                    .foregroundStyle(.red)
                                    .background(Color.black)
                            }
                        }
                    } else {
                        Image(systemName: "hammer.fill")
                            .frame(width: 400.0, height: 300.0)
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .background(Color.black)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.title)
                            Text(tool.description)
                                .padding(.trailing)
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                            Text("Price per day: \(tool.price) SEK")
                                .font(.headline)
                                .foregroundColor(Color.red)
                                .padding([.top, .bottom, .trailing])
                        }
                        .padding(.leading)
                        
                        Spacer()
                        VStack {
                            HStack {
                                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                    Image(systemName: "minus")
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                Text("\(quantity)")
                                    .font(.title3)
                                    .padding(10)
                                Button(action: { quantity += 1 }) {
                                    Image(systemName: "plus")
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                            }
                        }.padding(.trailing)
                    }
                    
                    VStack {
                        HStack {
                            Button("Pick Pickup Date") {
                                isPickingDate = true
                                isShowingDatePicker.toggle()
                            }
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            Spacer()
                            Text(dateFormatter.string(from: selectPickupDate))
                                .padding(.horizontal)
                                .font(.subheadline)
                        }
                        HStack {
                            Button("Pick Return Date") {
                                isPickingDate = false
                                isShowingDatePicker.toggle()
                            }
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            Spacer()
                            if let returnDate = selectReturnDate {
                                Text(dateFormatter.string(from: returnDate))
                                    .padding(.horizontal)
                                    .font(.subheadline)
                            } else {
                                Text("Select Date")
                                    .italic()
                                    .foregroundColor(.gray)
                                    .padding(.trailing)
                            }
                        }
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: {
                        if let returnDate = selectReturnDate {
                            cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: returnDate)
                            showConfirmation = true
                        }
                    }) {
                        Text("Add to Cart")
                            .frame(width: 200.0, height: 50.0)
                            .background(isAddToCartEnabled ? Color.green : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isAddToCartEnabled)
                    .padding()
                }
                .padding()
                
                if isShowingDatePicker {
                    VStack {
                        DatePicker(
                            "Select Date",
                            selection: isPickingDate ? $selectPickupDate : Binding(
                                get: { selectReturnDate ?? Date() },
                                set: { selectReturnDate = $0 }
                            ),
                            in: Date.now...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        Button("Done") {
                            handleDateSelection(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                }
            }
            .navigationTitle("Equipment Details")
            .alert("Added to Cart", isPresented: $showConfirmation) {
                Button("OK") {
                    dismiss() // Navigate back to Search in TabsView
                }
            } message: {
                Text("\(quantity) x \(tool.name) added to your cart.")
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

