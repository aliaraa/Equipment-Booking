//
//  EquipmentListingView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct EquipmentListingView: View {
    @StateObject private var viewModel = EquipmentListingViewModel()
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var navigateToCart = false // State to control cart navigation

    // Filtered Equipment List
    var filteredEquipments: [Tool] {
        viewModel.equipments.filter { equipment in
            (selectedCategory == "All" || equipment.category == selectedCategory) &&
            (searchText.isEmpty || equipment.name.localizedCaseInsensitiveContains(searchText) == true)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                HStack {
                    TextField("Search equipment...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Menu {
                        Button("All", action: { selectedCategory = "All" })
                        Button("Construction", action: { selectedCategory = "Construction" })
                        Button("Electrical", action: { selectedCategory = "Electrical" })
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.top)

                // Equipment List
                List {
                    ForEach(filteredEquipments) { equipment in
                        HStack(alignment: .top) {
                            // Equipment Image
                            AsyncImage(url: URL(string: equipment.imageURL ?? "")) { image in
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            .shadow(radius: 10)

                            // Equipment Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(equipment.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(equipment.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if equipment.status == "available" {
                                    Button(action: {
                                        addToCart(equipment: equipment)
                                    }) {
                                        Text("Add to Cart")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(5)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(5)
                                    }
                                } else if equipment.status == "rented" {
                                    Text("Expected Return: yyyy-mm-dd")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Spacer()

                // Footer Section with Home, Cart, and Profile Buttons
                HStack {
                    // Home Button - Reloads Equipment List
                    Button(action: {
                        Task {
                            try await viewModel.fetchEquipments() // Reloads the equipment list
                        }
                    }) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    // Cart Button - Navigates to Empty Cart View
                    NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                        Button(action: { navigateToCart = true }) {
                            Image(systemName: "cart")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    }

                    Spacer()

                    // User Profile Button (Moved from Toolbar to Footer)
                    NavigationLink(destination: UserProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .frame(height: 60)
                .padding(.horizontal)
            }
            .navigationTitle("Equipment List")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                try? await viewModel.fetchEquipments()
            }
        }
    }

    // Function to Handle Adding to Cart
    private func addToCart(equipment: Tool) {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }

        // Generate Booking ID
        let bookingID = EquipmentManager.shared.generateBookingID(firstName: authUser.firstName ?? "Guest", lastName: authUser.lastName ?? "User")

        // Create Rental Data
        let rental: [String: Any] = [
            "Date_out": Date(),
            "rented_items": [equipment.id],
            "expected_return_date": Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            "user_id": authUser.uid
        ]

        // Save to Firebase Rentals Collection
        Firestore.firestore().collection("rentals").document(bookingID).setData(rental) { error in
            if let error = error {
                print("Error adding rental: \(error)")
                return
            }

            // Update Equipment Status to "booked"
            Firestore.firestore().collection("equipments").document(equipment.id).updateData(["availability_status": "booked"]) { error in
                if let error = error {
                    print("Error updating equipment status: \(error)")
                }
            }
        }
    }
}

// Placeholder Cart View
struct CartView_2: View {
    @Environment(\.presentationMode) var presentationMode // For back navigation

    var body: some View {
        NavigationStack {
            VStack {
                Text("Cart is Empty")
                    .font(.title)
                    .padding()

                Spacer()

                // Footer Section with Home and Profile Buttons
                HStack {
                    // Home Button - Navigate Back to EquipmentListingView
                    NavigationLink(destination: EquipmentListingView()) {
                        Image(systemName: "house.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    // User Profile Button
                    NavigationLink(destination: UserProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .frame(height: 60)
                .padding()
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EquipmentListingView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                EquipmentListingView()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

