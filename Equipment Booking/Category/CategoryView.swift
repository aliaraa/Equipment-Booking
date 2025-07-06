//
//  ConstructionView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

// Improved to also be used to display filtered results based on search text

struct CategoryView: View {
    var category: String? // Used for category-specific views
    var tools: [Tool]? // Used for search results
    var title: String
    var searchText: String? // Search query from Search view
    @StateObject private var dataManager = EquipmentDataManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var localSearchText = ""
    
    var displayedTools: [Tool] {
        if let tools = tools, searchText != nil {
            // For search results, use provided tools (already filtered by keywords)
            return tools
        } else if let category = category {
            // For category view, filter by category
            return dataManager.toolData.filter { tool in
                tool.category == category
            }
        }
        return []
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if tools == nil { // Show search field only for category views
                HStack(spacing: 12) {
                    TextField("Search in \(title)", text: $localSearchText)
                        .padding(.horizontal, 12)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        .font(Typography.body)
                        .accessibilityLabel("Search equipment in \(title) category")
                        .onChange(of: localSearchText) { newValue in
                            Task {
                                do {
                                    try await dataManager.fetchEquipmentFromFirebase(searchText: newValue, category: category)
                                } catch {
                                    print("Error fetching tools: \(error)")
                                }
                            }
                        }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            
            List(displayedTools) { tool in
                ToolRow(tool: tool)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(PlainListStyle())
            .overlay {
                if displayedTools.isEmpty {
                    Text(tools == nil ? "No equipment found in \(title)" : "No search results")
                        .font(Typography.body)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(Typography.title)
                    .foregroundColor(.primary)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            // Fetch tools for category views if not search results
            if tools == nil, let category = category {
                Task {
                    do {
                        print("Fetching tools for category: \(category)")
                        try await dataManager.fetchEquipmentFromFirebase(category: category)
                    } catch {
                        print("Error fetching tools for category \(category): \(error)")
                    }
                }
            }
        }
    }
}


