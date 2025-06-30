//
//  ConstructionView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

// Improved to also be used to display filtered results based on search text

struct CategoryView: View {
    var category: String?
    var tools: [Tool]?
    var title: String
    @StateObject private var dataManager = EquipmentDataManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var searchText = ""
    
    var displayedTools: [Tool] {
        if let tools = tools {
            // For search results, use provided tools and apply search filter
            return searchText.isEmpty ? tools : tools.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        } else if let category = category {
            // For category view, filter by category and search text
            return dataManager.toolData.filter { tool in
                (tool.category == category) &&
                (searchText.isEmpty || tool.name.localizedCaseInsensitiveContains(searchText))
            }
        }
        return []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Search...", text: $searchText)
                    .padding(.horizontal, 12)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .font(Typography.body) // Use a consistent font style
//                    .font(.system(size: 16, weight: .regular, design: .rounded))
                
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(searchText.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(true) // Disable button as search is handled by TextField
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            
            List(displayedTools) { tool in
                ToolRow(tool: tool)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle(title)
        .font(Typography.title) // Use a consistent font style
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .background(Color(.systemBackground))
    }
}


#Preview {
    CategoryView(category: "Construction", title: "Construction")
        .environmentObject(CartManager())
}
