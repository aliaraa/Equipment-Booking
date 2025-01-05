//
//  Search.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-01.
//

import SwiftUI

struct Search: View {
    @State private var tools = toolData
    @State private var searchText = ""
    @State private var isShowingResults = false
    
    var filteredTools: [Tool] {
        if searchText.isEmpty{
            return tools
        } else {
            return tools.filter{
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                VStack{
                    HStack {
                        TextField("Search...", text: $searchText)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                        
                        Button(action: {isShowingResults = true}) {
                            Image(systemName: "magnifyingglass")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .frame(maxWidth: 40, maxHeight: 60)
                                .background(searchText.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(8)
                                .padding([.top, .trailing])
                        }
                    }
                    
                    
               
                    NavigationLink(destination: ConstructionView()) {
                        Text("Construction")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.orange)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                    
                    NavigationLink(destination: IndustrialView()) {
                        Text("Industrial")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                        
                    NavigationLink(destination: ElectricalView()) {
                        Text("Electrical")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .padding([.top, .leading, .trailing])
                    }
                    Spacer()
                } //Vstack
                .sheet(isPresented: $isShowingResults) {
                    SearchResultsView(tools: filteredTools)
                }
            } //Navigation
        }
    }
}

#Preview {
    Search()
        .environmentObject(CartManager())
}
