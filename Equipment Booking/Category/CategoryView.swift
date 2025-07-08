//
//  ConstructionView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

// Improved to also be used to display filtered results based on search text
// Added filtering and sorting capabilities


struct CategoryView: View {
    var category: String? // Used for category-specific views
    var tools: [Tool]? // Used for search results
    var title: String
    var searchText: String? // Search query from Search view
    @StateObject private var dataManager = EquipmentDataManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var localSearchText = ""
    @State private var showFilterSortSheet = false
    @State private var selectedManufacturer: String? = nil
    @State private var selectedMainCategory: String? = nil
    @State private var selectedSubCategory: String? = nil
    @State private var sortOption: SortOption = .nameAscending
    
    // Sorting options
    enum SortOption: String, CaseIterable, Identifiable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case priceAscending = "Price (Low to High)"
        case priceDescending = "Price (High to Low)"
        case availability = "Availability"
        var id: String { rawValue }
    }
    
    // Computed property for displayed tools with filters and sorting
    var displayedTools: [Tool] {
        var filteredTools: [Tool]
        if let tools = tools, searchText != nil {
            // For search results, use provided tools
            filteredTools = tools
        } else if let category = category {
            // For category view, filter by category
            filteredTools = dataManager.toolData.filter { tool in
                tool.category == category
            }
        } else {
            filteredTools = []
        }
        
        // Apply filters
        if let manufacturer = selectedManufacturer {
            filteredTools = filteredTools.filter { $0.manufacturer == manufacturer }
        }
        if let mainCategory = selectedMainCategory {
            filteredTools = filteredTools.filter { $0.mainCategory == mainCategory }
        }
        if let subCategory = selectedSubCategory {
            filteredTools = filteredTools.filter { $0.subCategory == subCategory }
        }
        
        // Apply sorting
        switch sortOption {
        case .nameAscending:
            return filteredTools.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .nameDescending:
            return filteredTools.sorted { $0.name.lowercased() > $1.name.lowercased() }
        case .priceAscending:
            return filteredTools.sorted { $0.price < $1.price }
        case .priceDescending:
            return filteredTools.sorted { $0.price > $1.price }
        case .availability:
            return filteredTools.sorted { $0.isAvailable && !$1.isAvailable }
        }
    }
    
    // Unique values for filters
    var uniqueManufacturers: [String] {
        Array(Set((tools ?? dataManager.toolData).map { $0.manufacturer })).sorted()
    }
    var uniqueMainCategories: [String] {
        Array(Set((tools ?? dataManager.toolData).map { $0.mainCategory })).sorted()
    }
    var uniqueSubCategories: [String] {
        Array(Set((tools ?? dataManager.toolData).map { $0.subCategory })).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilterSortSheet = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Filter and sort results")
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showFilterSortSheet) {
            FilterSortSheet(
                selectedManufacturer: $selectedManufacturer,
                selectedMainCategory: $selectedMainCategory,
                selectedSubCategory: $selectedSubCategory,
                sortOption: $sortOption,
                manufacturers: uniqueManufacturers,
                mainCategories: uniqueMainCategories,
                subCategories: uniqueSubCategories
            )
            .presentationDetents([.medium, .large])
            .presentationBackground(.ultraThinMaterial)
        }
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

struct FilterSortSheet: View {
    @Binding var selectedManufacturer: String?
    @Binding var selectedMainCategory: String?
    @Binding var selectedSubCategory: String?
    @Binding var sortOption: CategoryView.SortOption
    let manufacturers: [String]
    let mainCategories: [String]
    let subCategories: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Filter by")) {
                    Picker("Manufacturer", selection: $selectedManufacturer) {
                        Text("All")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .tag(String?.none)
                        
                        ForEach(manufacturers, id: \.self) { manufacturer in
                            Text(manufacturer)
                                .tag(String?.some(manufacturer))
                                .font(Typography.body)
                        }
                    }
                    Picker("Main Category", selection: $selectedMainCategory) {
                        Text("All")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .tag(String?.none)
                        ForEach(mainCategories, id: \.self) { category in
                            Text(category)
                                .tag(String?.some(category))
                                .font(Typography.body)
                        }
                    }
                    Picker("Sub Category", selection: $selectedSubCategory) {
                        Text("All")
                            .font(Typography.body)
                            .fontWeight(.bold)
                            .tag(String?.none)
                        ForEach(subCategories, id: \.self) { subCategory in
                            Text(subCategory)
                                .font(Typography.body)
                                .tag(String?.some(subCategory))
                        }
                    }
                }
                Section(header: Text("Sort by")) {
                    Picker("Sort Option", selection: $sortOption) {
                        ForEach(CategoryView.SortOption.allCases) { option in
                            Text(option.rawValue)
                                .font(Typography.body)
                                .tag(option)
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width - 32) // Match CategoryView content width
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        selectedManufacturer = nil
                        selectedMainCategory = nil
                        selectedSubCategory = nil
                        sortOption = .nameAscending
                    }
                    .font(Typography.body)
                    .foregroundColor(.red)
                    .padding()
                    
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(Typography.body)
                        .foregroundColor(.blue)
                        .padding()
                }
                
            }
            
        }
    }
}


