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

//struct CategoryView: View {
//
//
//    var category: String
//    var title: String
//    @StateObject private var dataManager = EquipmentDataManager()
//    @EnvironmentObject var cartManager: CartManager
//    @State private var searchText = ""
//    @State private var isShowingResults = false
//
//    var filteredTools: [Tool] {
//        dataManager.toolData.filter { tool in
//            (tool.category == category) &&
//            (searchText.isEmpty || tool.name.localizedCaseInsensitiveContains(searchText))
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Sökfält och knapp
//            HStack(spacing: 12) {
//                TextField("Search...", text: $searchText)
//                    .padding(.horizontal, 12)
//                    .frame(height: 50)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                    )
//                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
//
//                Button(action: { isShowingResults = true }) {
//                    Image(systemName: "magnifyingglass")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(width: 50, height: 50)
//                        .background(searchText.isEmpty ? Color.gray : Color.blue)
//                        .cornerRadius(12)
//                        .shadow(color: searchText.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 10)
//
//            // Lista utan chevron och separators
//            List(isShowingResults ? filteredTools : dataManager.toolData.filter { $0.category == category }) { tool in
//                ToolRow(tool: tool)
//                    .listRowSeparator(.hidden) // Tar bort linjen mellan items
//                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Justerar padding
//            }
//            .listStyle(PlainListStyle())
//            .onChange(of: searchText) { newValue in
//                if newValue.isEmpty {
//                    isShowingResults = false
//                }
//            }
//        }
//        .navigationTitle("\(title) Tools")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("\(title) Tools")
//                    .font(.system(size: 22, weight: .bold, design: .rounded)) // Uppdaterad typografi
//                    .foregroundColor(.primary)
//            }
//        }
//        .background(Color(.systemBackground))
//    }
//}
