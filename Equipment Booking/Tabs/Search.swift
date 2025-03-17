import SwiftUI
import Firebase
import FirebaseFirestore

struct Search: View {
    @StateObject private var dataManager = EquipmentDataManager()
    @State private var searchText = ""
    @State private var isShowingResults = false
    
    var filteredTools: [Tool] {
        if searchText.isEmpty {
            return dataManager.toolData
        } else {
            return dataManager.toolData.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
           
                VStack {
                    HStack {
                        TextField("Search...", text: $searchText)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                        
                        Button(action: { isShowingResults = true }) {
                            Image(systemName: "magnifyingglass")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: 40, maxHeight: 60)
                                .background(searchText.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(8)
                                .padding([.top, .trailing])
                        }
                    }
                    
                    NavigationLink(destination: CategoryView(category: "Construction", title: "Construction")) {
                        Text("Construction")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                    
                    NavigationLink(destination: CategoryView(category: "Industrial", title: "Industrial")) {
                        Text("Industrial")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                    
                    NavigationLink(destination: CategoryView(category: "Electrical", title: "Electrical")) {
                        Text("Electrical")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                    
                    Spacer()
                }
                .sheet(isPresented: $isShowingResults) {
                    SearchResultsView(tools: filteredTools)
                }
            }
        }
    }


#Preview {
    Search()
        .environmentObject(CartManager())
}
