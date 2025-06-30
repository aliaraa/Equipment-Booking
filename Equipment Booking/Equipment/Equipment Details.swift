// Equipment_Details.swift
// Equipment Booking
//
// Created by Ali Ara on 2025-01-05.


import SwiftUI

// Improved layout for iPhone 14
// - Increase VStack spacing to 24 pt and section padding to 20 pt.
// - Use 16 pt fonts for secondary text and 18 pt for primary text.
// - Ensure buttons are at least 44x44 pt.
//

struct Equipment_Details: View {
    let tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var equipmentManager = EquipmentManager.shared
    @State private var selectPickupDate: Date = Date()
    @State private var selectReturnDate: Date? = nil
    @State private var isShowingDatePicker: Bool = false
    @State private var isPickingDate: Bool = true
    @State private var quantity: Int = 1
    @State private var availableQuantity: Int = 0
    @State private var totalQuantity: Int = 0
    @State private var availabilityMessage: String = ""
    @State private var nextAvailableDate: Date = Date()
    @State private var showConfirmation: Bool = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isAddToCartEnabled: Bool {
        availableQuantity >= quantity && selectReturnDate != nil && selectPickupDate <= selectReturnDate ?? Date.distantFuture
    }
    
    private func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
            if selectReturnDate == nil || selectReturnDate! < date {
                selectReturnDate = Calendar.current.date(byAdding: .day, value: 7, to: date)
            }
        } else {
            selectReturnDate = date
        }
        isShowingDatePicker = false
    }
    
    private func updateAvailability() {
        guard let returnDate = selectReturnDate else {
            availableQuantity = 0
            availabilityMessage = "Please select a return date."
            return
        }
        Task {
            do {
                let (bookings, available) = try await equipmentManager.getToolAvailability(
                    forToolId: tool.id,
                    pickupDate: selectPickupDate,
                    returnDate: returnDate
                )
                DispatchQueue.main.async {
                    self.totalQuantity = tool.numberOfItems
                    self.availableQuantity = available
                    self.availabilityMessage = bookings.isEmpty ? "" : "Some units are booked during this period."
                }
            } catch {
                print("Error checking availability: \(error)")
                DispatchQueue.main.async {
                    self.availableQuantity = 0
                    self.availabilityMessage = "Error checking availability."
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ToolImageSection(imageURL: tool.imageURL!)
                ToolDetailsSection(
                    name: tool.name,
                    description: tool.description,
                    price: tool.price,
                    availableQuantity: availableQuantity,
                    availabilityMessage: availabilityMessage
                )
                QuantityPickerSection(
                    quantity: $quantity,
                    availableQuantity: availableQuantity
                )
                BookingDatesSection(
                    selectPickupDate: $selectPickupDate,
                    selectReturnDate: $selectReturnDate,
                    isShowingDatePicker: $isShowingDatePicker,
                    isPickingDate: $isPickingDate,
                    dateFormatter: dateFormatter
                )
                AddToCartButtonSection(
                    isAuthenticated: authViewModel.isAuthenticated,
                    isAddToCartEnabled: isAddToCartEnabled,
                    selectReturnDate: selectReturnDate,
                    showConfirmation: $showConfirmation,
                    onAddToCart: {
                        cartManager.addToCart(
                            tool,
                            quantity: quantity,
                            pickupDate: selectPickupDate,
                            returnDate: selectReturnDate!
                        )
                    }
                )
            }
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Equipment Details")
                    .font(Typography.title)
                    .foregroundColor(.primary)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 50)
        }
        .sheet(isPresented: $isShowingDatePicker) {
            DatePickerSheet(
                isPickingDate: isPickingDate,
                selectPickupDate: $selectPickupDate,
                selectReturnDate: $selectReturnDate,
                nextAvailableDate: nextAvailableDate,
                onApply: handleDateSelection
            )
        }
        .alert("Added to Cart", isPresented: $showConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("\(quantity) x \(tool.name) added to your cart.")
                .font(Typography.body)
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

struct ToolDetailsSection: View {
    let name: String
    let description: String
    let price: Double
    let availableQuantity: Int
    let availabilityMessage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(Typography.title)
                .foregroundColor(.primary)

            Text(description)
                .font(Typography.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)

            HStack(spacing: 8) {
                Text("Price:")
                    .font(Typography.subheadline)
                    .foregroundColor(.primary)
                Text("\(price, specifier: "%.2f") SEK/day")
                    .font(Typography.subheadline)
                    .foregroundColor(.blue)
            }

            Text("Prices are for demonstration purposes only.")
                .font(Typography.caption)
                .foregroundColor(.gray)
                .italic()

            HStack(spacing: 8) {
                Text("Available:")
                    .font(Typography.subheadline)
                    .foregroundColor(.primary)
                Text("\(availableQuantity)")
                    .font(Typography.subheadline)
                    .foregroundColor(availableQuantity > 0 ? .green : .red)
                Spacer()
                Image(systemName: availableQuantity > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(availableQuantity > 0 ? .green : .red)
            }

            if !availabilityMessage.isEmpty {
                Text(availabilityMessage)
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

struct QuantityPickerSection: View {
    @Binding var quantity: Int
    let availableQuantity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quantity")
                .font(Typography.headline)
            HStack(spacing: 16) {
                Button(action: { if quantity > 1 { quantity -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(22)
                }
                Text("\(quantity)")
                    .font(Typography.body)
                    .frame(width: 50, alignment: .center)
                Button(action: { if quantity < availableQuantity { quantity += 1 } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(22)
                }
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct BookingDatesSection: View {
    @Binding var selectPickupDate: Date
    @Binding var selectReturnDate: Date?
    @Binding var isShowingDatePicker: Bool
    @Binding var isPickingDate: Bool
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booking Dates")
                .font(Typography.headline)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                Button(action: {
                    isPickingDate = true
                    isShowingDatePicker.toggle()
                }) {
                    Text("Pickup Date")
                        .font(Typography.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                }
                Spacer()
                Text(dateFormatter.string(from: selectPickupDate))
                    .font(Typography.body)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Button(action: {
                    isPickingDate = false
                    isShowingDatePicker.toggle()
                }) {
                    Text("Return Date")
                        .font(Typography.body)
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
                        .font(Typography.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("Select Date")
                        .font(Typography.body)
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
    }
}

struct AddToCartButtonSection: View {
    let isAuthenticated: Bool
    let isAddToCartEnabled: Bool
    let selectReturnDate: Date?
    @Binding var showConfirmation: Bool
    let onAddToCart: () -> Void

    var body: some View {
        VStack {
            if isAuthenticated {
                Button(action: {
                    if selectReturnDate != nil {
                        onAddToCart()
                        showConfirmation = true
                    }
                }) {
                    Text("Add to Cart")
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isAddToCartEnabled ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(isAddToCartEnabled ? 0.3 : 0), radius: 4, x: 0, y: 2)
                }
            } else {
                NavigationLink(destination: UserAuthenticationView()) {
                    Text("Sign In to Add to Cart")
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

struct DatePickerSheet: View {
    let isPickingDate: Bool
    @Binding var selectPickupDate: Date
    @Binding var selectReturnDate: Date?
    let nextAvailableDate: Date
    let onApply: (Date) -> Void

    var body: some View {
        VStack(spacing: 12) {
            DatePicker(
                "Select Date",
                selection: isPickingDate ? $selectPickupDate : Binding(
                    get: { selectReturnDate ?? Date() },
                    set: { selectReturnDate = $0 }
                ),
                in: nextAvailableDate...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()

            Button(action: {
                onApply(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
            }) {
                Text("Apply")
                    .font(Typography.body)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 8)
        .presentationDetents([.medium])
    }
}

struct ToolImageSection: View {
    let imageURL: String

    var body: some View {
        ToolImageView(imageURL: imageURL)
            .frame(height: 250)
            .padding(.horizontal, 16)
            .padding(.top, 10)
    }
}

