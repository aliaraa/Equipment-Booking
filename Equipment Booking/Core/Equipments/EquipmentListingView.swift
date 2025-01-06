//
//  EquipmentListingView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

import SwiftUI

@MainActor
final class EquipmentsViewModel: ObservableObject {
    
    @Published private(set) var equipments: [Equipment] = []
    
    func getAllEquipments() async throws {
        self.equipments = try await EquipmentManager.shared.getAllEquipments()
    }
}

struct EquipmentListingView: View {
    
    @StateObject private var viewModel = EquipmentsViewModel()
    
    var body: some View {
        
        List {
            ForEach(viewModel.equipments) {
                equipment in
                HStack (alignment: .top){
                    
                    AsyncImage(url: URL(string: equipment.img_url ?? "")) {image in image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .cornerRadius(10)
                        
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                .frame(width: 75, height: 75)
                .shadow(radius: 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text(equipment.equipment_name ?? "n/a")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(equipment.availability_status ?? "n/a")
                    }
                    // Text(equipment.description ?? "n/a")
                    Text(equipment.description ?? "n/a")
                        .font(.callout)
                        .foregroundColor(.secondary)
                                        
                }
                
            }
            .navigationTitle("Equipments")
            .task {
                try? await viewModel.getAllEquipments()
            }
        }
    }
}

#Preview {
    NavigationStack {
        EquipmentListingView()}
}
