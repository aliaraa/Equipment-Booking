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


#Preview {
    CategoryView(category: "Construction", title: "Construction")
        .environmentObject(CartManager())
}



