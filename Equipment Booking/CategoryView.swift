//
//  ConstructionView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct CategoryView: View {
    var category: String
    var title: String
    @StateObject private var dataManager = EquipmentDataManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var searchText = ""
    @State private var isShowingResults = false
    
    var filteredTools: [Tool] {
        dataManager.toolData.filter { tool in
            (tool.category == category) &&
            (searchText.isEmpty || tool.name.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    TextField("Search in \(title)", text: $searchText)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding([.top, .leading])
                    
                    Button(action: { isShowingResults.toggle() }) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: 40, maxHeight: 50)
                            .background(searchText.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(8)
                            .padding([.top, .trailing])
                    }
                    .disabled(searchText.isEmpty)
                }
                
                List(isShowingResults ? filteredTools : dataManager.toolData.filter { $0.category == category }) { tool in
                    ToolRow(tool: tool)
                }
                .listStyle(PlainListStyle())
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
                        isShowingResults = false
                    }
                }
                
                footer
            }
            .navigationTitle("\(title) Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(title) Tools")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
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


#Preview {
    CategoryView(category: "Construction", title: "Construction")
        .environmentObject(CartManager())
}


//struct CategoryView: View {
//    
//    var category: String
//    var title: String
////    @State private var tools = toolData
//    @StateObject private var dataManager = EquipmentDataManager() //Replace tools with dataManager.toolData
//    @State private var searchText = ""
//    @State private var isShowingResults = false
//    
//    var filteredTools: [Tool] {
//      
//            //        tools.filter { tool in
//            dataManager.toolData.filter { tool in
//                (tool.category == category) &&
//                (searchText.isEmpty || tool.name.localizedCaseInsensitiveContains(searchText))
//            }
//        }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                TextField("Search in \(title)", text: $searchText)
//                    .padding(.leading)
//                    .frame(maxWidth: .infinity, maxHeight: 50)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//                    .padding([.top, .leading])
//                
//                Button(action: {isShowingResults.toggle()}) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: 40, maxHeight: 50)
//                        .background(searchText.isEmpty ? Color.gray : Color.blue)
//                        .cornerRadius(8)
//                        .padding([.top, .trailing])
//                }
//                .disabled(searchText.isEmpty)
//            }// Hstack
//            
//            List(isShowingResults ? filteredTools : dataManager.toolData.filter{$0.category == category}) { tool in
//                NavigationLink(destination: Equipment_Details(tool: tool)) {
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(tool.name)
//                                .font(.headline)
//                            Text(tool.description)
//                                .font(.subheadline)
//                                .foregroundColor(Color.gray)
//                            Text("Price Per Day: \(tool.price)$")
//                                .foregroundColor(Color.red)
//                                .font(.caption)
//                        }
//                        Spacer()
//                        if tool.isAvailable {
//                            Text("Available")
//                                .font(.caption)
//                                .foregroundColor(Color.green)
//                        } else {
//                            Text("Unavailable")
//                                .font(.caption)
//                                .foregroundColor(Color.red)
//                        }
//                    } //Hstack
//                } //Navigationlink
//            } //List
//            .onChange(of: searchText) { newValue in
//                if newValue.isEmpty {
//                    isShowingResults = false
//                }
//            }
//            Spacer()
//        } //Vstack
//        .navigationTitle("\(title) Tools")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("\(title) Tools")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//            }
//        }
//    }
//}
//
//#Preview {
//    CategoryView(category: "Construction", title: "Construction")
//        .environmentObject(CartManager())
//}
