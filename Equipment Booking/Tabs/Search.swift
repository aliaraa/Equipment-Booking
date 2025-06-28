import SwiftUI
import Firebase
import FirebaseFirestore

// Improved CartView and CartRow UI for iPhone 14 size
// - Increased VStack spacing to 24pt and CategoryCard spacing to 20pt
// - Reduced search button size to 44x44 pt and added padding
// - Dynamic card heights
// - redirected navigation to category view for search results display

struct Search: View {
    @StateObject private var dataManager = EquipmentDataManager()
    @State private var searchText = ""
    
    var filteredTools: [Tool] {
        if searchText.isEmpty { return dataManager.toolData }
        return dataManager.toolData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    TextField("Search...", text: $searchText)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        .font(Typography.body) // Use Typography for consistent styling
//                       .font(.system(size: 16, weight: .regular, design: .rounded))
                    
                    NavigationLink(
                        destination: CategoryView(tools: filteredTools, title: "Search Results")
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
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .font(Typography.title) // Use Typography for consistent styling
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
//                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .font(Typography.headline) // Use Typography for consistent styling
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(color)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Search()
        .environmentObject(CartManager())
}



//struct Search: View {
//    @StateObject private var dataManager = EquipmentDataManager()
//    @State private var searchText = ""
//    @State private var isShowingResults = false
//    
//    var filteredTools: [Tool] {
//        if searchText.isEmpty { return dataManager.toolData }
//        return dataManager.toolData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 24) { // Increased spacing
//                HStack(spacing: 12) {
//                    TextField("Search...", text: $searchText)
//                        .padding(.horizontal, 12)
//                        .frame(height: 44) // Adjusted height
//                        .background(Color(.systemGray6))
//                        .cornerRadius(12)
//                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
//                    
//                    Button(action: { isShowingResults = true }) {
//                        Image(systemName: "magnifyingglass")
//                            .font(.system(size: 18, weight: .semibold))
//                            .frame(width: 44, height: 44) // Adjusted size
//                            .background(searchText.isEmpty ? Color.gray : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 10)
//                
//                VStack(spacing: 20) { // Increased spacing
//                    CategoryCard(category: "Construction", destination: CategoryView(category: "Construction", title: "Construction"), color: Color.orange)
//                    CategoryCard(category: "Industrial", destination: CategoryView(category: "Industrial", title: "Industrial"), color: Color.gray)
//                    CategoryCard(category: "Electrical", destination: CategoryView(category: "Electrical", title: "Electrical"), color: Color.yellow)
//                }
//                .padding(.horizontal, 16)
//                
//                Spacer()
//            }
//            .background(Color(.systemBackground))
//            .navigationTitle("Search")
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $isShowingResults) {
//                SearchResultsView(tools: filteredTools)
//            }
//        }
//    }
//}

//struct CategoryCard: View {
//    let category: String
//    let destination: CategoryView
//    let color: Color
//    
//    var body: some View {
//        NavigationLink(destination: destination) {
//            Text(category)
//                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, minHeight: 80) // Dynamic height
//                .background(color)
//                .cornerRadius(12)
//                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
//        }
//        .padding(.vertical, 4)
//    }
//}

//struct Search: View {
//    @StateObject private var dataManager = EquipmentDataManager()
//    @State private var searchText = ""
//    @State private var isShowingResults = false
//    
//    var filteredTools: [Tool] {
//        if searchText.isEmpty {
//            return dataManager.toolData
//        } else {
//            return dataManager.toolData.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                // Sökfält och knapp
//                HStack(spacing: 12) {
//                    TextField("Search...", text: $searchText)
//                        .padding(.horizontal, 12)
//                        .frame(height: 50)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
//                    
//                    Button(action: { isShowingResults = true }) {
//                        Image(systemName: "magnifyingglass")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(width: 50, height: 50)
//                            .background(searchText.isEmpty ? Color.gray : Color.blue)
//                            .cornerRadius(12)
//                            .shadow(color: searchText.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 10)
//                
//                // Kategorier
//                VStack(spacing: 16) {
//                    CategoryCard(category: "Construction", destination: CategoryView(category: "Construction", title: "Construction"), color: Color.orange)
//                    CategoryCard(category: "Industrial", destination: CategoryView(category: "Industrial", title: "Industrial"), color: Color.gray)
//                    CategoryCard(category: "Electrical", destination: CategoryView(category: "Electrical", title: "Electrical"), color: Color.yellow)
//                }
//                .padding(.horizontal, 16)
//                
//                Spacer()
//            }
//            .background(Color(.systemBackground))
//            .navigationTitle("Search")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Search")
//                        .font(.system(size: 22, weight: .bold, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//            }
//            .sheet(isPresented: $isShowingResults) {
//                SearchResultsView(tools: filteredTools)
//            }
//        }
//    }
//}
//
//// Hjälpkomponent för kategorikort
//struct CategoryCard: View {
//    let category: String
//    let destination: CategoryView
//    let color: Color
//    
//    var body: some View {
//        NavigationLink(destination: destination) {
//            Text(category)
//                .font(.system(size: 20, weight: .semibold, design: .rounded))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, minHeight: 100)
//                .background(color)
//                .cornerRadius(12)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
//        }
//    }
//}

#Preview {
    Search()
        .environmentObject(CartManager())
}
