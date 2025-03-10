//
//  SearchResultsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct SearchResultsView: View {
    var tools: [Tool]
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        NavigationStack {
            VStack {
                List(tools) { tool in
                    ToolRow(tool: tool)
                }
                .listStyle(PlainListStyle())
                
                footer
            }
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var footer: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(maxWidth: .infinity)
            
            NavigationLink(destination: CartView()) {
                Image(systemName: "cart")
                    .font(.title2)
                    .foregroundColor(cartManager.cartItems.isEmpty ? .gray : .blue)
                    .overlay(
                        cartManager.cartItems.isEmpty ? nil :
                            Text("\(cartManager.cartItems.count)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10),
                        alignment: .topTrailing
                    )
            }
            .frame(maxWidth: .infinity)
            
            NavigationLink(destination: UserProfileView()) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20) // Padding at ends
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}


let exampleTool1 = Tool(
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

let exampleTool2 = Tool(
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
    SearchResultsView(tools: [exampleTool1, exampleTool2])
        .environmentObject(CartManager())
}



//struct SearchResultsView: View {
//    
//    var tools: [Tool]
//    
//    var body: some View {
//        if #available(iOS 16.0, *) {
//            NavigationStack {
//                List(tools) { tool in
//                    VStack(alignment: .leading) {
//                        Text(tool.name)
//                            .font(.headline)
//                        Text(tool.description)
//                            .font(.subheadline)
//                            .foregroundColor(Color.gray)
//                        Text("Price per day: \(tool.price)$")
//                            .foregroundColor(Color.red)
//                            .font(.caption)
//                        if tool.isAvailable {
//                            Text("Available")
//                                .font(.caption)
//                                .foregroundColor(Color.green)
//                        } else {
//                            Text("Unavailable")
//                                .font(.caption)
//                                .foregroundColor(Color.red)
//                        }
//                    }
//                }
//                .navigationTitle("Search Results")
//                .navigationBarTitleDisplayMode(.inline)
//            }
//        }
//    }
//}
//
//#Preview {
//    Search()
//        .environmentObject(CartManager())
//}
