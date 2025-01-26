//
//  EquipmentListingView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

//@MainActor
//final class EquipmentsViewModel: ObservableObject {
//
//    @Published private(set) var equipments: [Equipment] = []
//
//    func getAllEquipments() async throws {
//        self.equipments = try await EquipmentManager.shared.getAllEquipments()
//    }
//}

struct EquipmentListingView: View {
    @StateObject private var viewModel = EquipmentListingViewModel()
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var showUserProfile: Bool = false // State to navigate to UserProfileView
    
    
    // Filtered Equipment List
    var filteredEquipments: [Equipment] {
        viewModel.equipments.filter { equipment in
            (selectedCategory == "All" || equipment.equipment_main_category == selectedCategory) &&
            (searchText.isEmpty || equipment.equipment_name?.localizedCaseInsensitiveContains(searchText) == true)
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
                        Button("Construction Cranes", action: { selectedCategory = "Construction Cranes" })
                        Button("Power Tools", action: { selectedCategory = "Power Tools" })
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
                            AsyncImage(url: URL(string: equipment.img_url ?? "")) { image in
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
                                Text(equipment.equipment_name ?? "n/a")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(equipment.description ?? "No description available")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if equipment.availability_status == "available" {
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
                                } else if equipment.availability_status == "rented" {
                                    Text("Expected Return: yyyy-mm-dd")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Equipment List")
            .toolbar {
                // Profile Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
            }
            .task {
                try? await viewModel.fetchEquipments()
            }
        }
        
        
    }
    
    
    // Old equipListingView
    
    //    var body: some View {
    //
    //
    //        NavigationView {
    //            VStack {
    //                // Search and Filter
    //                HStack {
    //                    TextField("Search equipment...", text: $searchText)
    //                        .textFieldStyle(RoundedBorderTextFieldStyle())
    //                        .padding(.horizontal)
    //
    //                    Menu {
    //                        Button("All", action: { selectedCategory = "All" })
    //                        Button("Construction Cranes", action: { selectedCategory = "Construction Cranes" })
    //                        Button("Power Tools", action: { selectedCategory = "Power Tools" })
    //                        // Add other categories here
    //                    } label: {
    //                        HStack {
    //                            Text(selectedCategory)
    //                                .font(.subheadline)
    //                                .foregroundColor(.blue)
    //                            Image(systemName: "arrowtriangle.down.fill")
    //                                .font(.caption)
    //                                .foregroundColor(.blue)
    //                        }
    //                        .padding(.trailing)
    //                    }
    //                }
    //                .padding(.top)
    //
    //                // Equipment List
    //                List {
    //                    ForEach(filteredEquipments) { equipment in
    //                        HStack(alignment: .top) {
    //                            // Equipment Image
    //                            AsyncImage(url: URL(string: equipment.img_url ?? "")) { image in
    //                                image.resizable()
    //                                    .scaledToFit()
    //                                    .frame(width: 75, height: 75)
    //                                    .cornerRadius(10)
    //                            } placeholder: {
    //                                ProgressView()
    //                            }
    //                            .shadow(radius: 10)
    //
    //                            // Equipment Details
    //                            VStack(alignment: .leading, spacing: 4) {
    //                                Text(equipment.equipment_name ?? "n/a")
    //                                    .font(.headline)
    //                                    .foregroundColor(.primary)
    //
    //                                Text(equipment.description ?? "No description available")
    //                                    .font(.subheadline)
    //                                    .foregroundColor(.secondary)
    //
    //                                if equipment.availability_status == "available" {
    //                                    // Add to Cart Button
    //                                    Button(action: {
    //                                        addToCart(equipment: equipment)
    //                                    }) {
    //                                        Text("Add to Cart")
    //                                            .font(.caption)
    //                                            .foregroundColor(.blue)
    //                                            .padding(5)
    //                                            .background(Color.gray.opacity(0.2))
    //                                            .cornerRadius(5)
    //                                    }
    //                                } else if equipment.availability_status == "rented" {
    //                                    // Display Expected Return Date
    //                                    Text("Expected Return: yyyy-mm-dd")
    //                                        .font(.caption)
    //                                        .foregroundColor(.red)
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //                .listStyle(InsetGroupedListStyle())
    //            }
    //            .navigationTitle("Equipment List")
    //            .toolbar {
    //                // Profile Button
    //                ToolbarItem(placement: .navigationBarTrailing) {
    //                    NavigationLink(destination: ProfileView(showSignInView:.constant(false))) {
    //                        Image(systemName: "person.circle")
    //                            .font(.title2)
    //                    }
    //                }
    //            }
    //            .task {
    //                try? await viewModel.fetchEquipments()
    //            }
    //        }
    //    }
    
    
    // Function to Handle Adding to Cart
    private func addToCart(equipment: Equipment) {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
        // Generate Booking ID
        let bookingID = EquipmentManager.shared.generateBookingID(firstName: authUser.firstName ?? "Guest", lastName: authUser.lastName ?? "User")
        
        // Create Rental Data
        let rental: [String: Any] = [
            "Date_out": Date(),
            "rented_items": [equipment.equip_id],
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
            Firestore.firestore().collection("equipments").document(equipment.equip_id).updateData(["availability_status": "booked"]) { error in
                if let error = error {
                    print("Error updating equipment status: \(error)")
                }
            }
        }
    }
}


//        List {
//            ForEach(viewModel.equipments) {
//                equipment in
//                HStack (alignment: .top){
//
//                    AsyncImage(url: URL(string: equipment.img_url ?? "")) {image in image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 75, height: 75)
//                            .cornerRadius(10)
//
//                    } placeholder: {
//                        ProgressView()
//                    }
//                }
//
//                .frame(width: 75, height: 75)
//                .shadow(radius: 10)
//
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack{
//                        Text(equipment.equipment_name ?? "n/a")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        Text(equipment.availability_status ?? "n/a")
//                    }
//                    // Text(equipment.description ?? "n/a")
//                    Text(equipment.description ?? "n/a")
//                        .font(.callout)
//                        .foregroundColor(.secondary)
//
//                }
//
//            }
//            .navigationTitle("Equipments")
//
//            .task {
//                try? await viewModel.getAllEquipments()
//            }
//        }


struct EquipmentListingView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                EquipmentListingView ()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
