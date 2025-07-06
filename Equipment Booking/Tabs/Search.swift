import SwiftUI
import Firebase
import FirebaseFirestore

// Improved SearchView for iPhone 14 size
// - Increased VStack spacing to 24pt and CategoryCard spacing to 20pt
// - Reduced search button size to 44x44 pt and added padding
// - Dynamic card heights
// - redirected navigation to category view for search results display

// Update 1 - Enhanced filteredTools to include all tools attributes (description, category, manufacturer, etc...)


//  Searches name, description, category, mainCategory, subCategory, and manufacturer using a combined searchableFields array.
//  Splits searchText into words (queryWords) and uses allSatisfy to ensure every query word matches at least one field, enabling flexible matching (e.g., “power tool” matches “power” in name and “tool” in description).
//  Trims whitespace and converts to lowercase for consistency.


struct Search: View {
    @StateObject private var dataManager = EquipmentDataManager()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    TextField("Search by name, description or category", text: $searchText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        .font(Typography.body)
                        .accessibilityLabel("Search equipment by name, description, or category")
                        .onChange(of: searchText) { newValue in
                            Task {
                                do {
                                    try await dataManager.fetchEquipmentFromFirebase(searchText: newValue)
                                } catch {
                                    print("Error fetching tools: \(error)")
                                }
                            }
                        }
                    
                    NavigationLink(
                        destination: CategoryView(tools: dataManager.toolData, title: "Search Results", searchText: searchText)
                    ) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(searchText.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                VStack(spacing: 20) {
                    CategoryCard(category: "Construction", destination: CategoryView(category: "Construction", title: "Construction"), color: Color.orange)
                    CategoryCard(category: "Industrial", destination: CategoryView(category: "Industrial", title: "Industrial"), color: Color.gray)
                    CategoryCard(category: "Electrical", destination: CategoryView(category: "Electrical", title: "Electrical"), color: Color.yellow)
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(Typography.title)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: String
    let destination: CategoryView
    let color: Color
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(category)
                .font(Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(color)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
        }
        .padding(.vertical, 4)
    }
}

