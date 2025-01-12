//
//  EquipmentListingView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import SwiftUI

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
    
    var body: some View {
        
        
        ScrollView {
            
            ForEach(viewModel.equipments) { equipment in
                
                HStack (alignment: .top, spacing: 12){
                    
                    AsyncImage(url: URL(string: equipment.img_url ?? "")) {image in image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .cornerRadius(10)
                        
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .shadow(radius: 10)
                            
                    VStack(alignment: .leading, spacing: 4 ) {
                        
                        Text (equipment.equipment_name ?? "n/a")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text (equipment.description ?? "n/a")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Text ("Price: SEK\(equipment.rental_price_per_day ?? 0, specifier: "%.2f")")
                            .font(.body)
                            .foregroundColor(.green)
                        
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
            
            
        }
        
    }
        .navigationTitle("Equipment Listing")
        .onAppear {
            viewModel.fetchEquipments()
        }
    
    
    }
    
    //        }
    
    
    
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


