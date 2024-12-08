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
    
    var filteredTools: [Tool] {
        if searchText.isEmpty{
            return tools
        } else {
            return tools.filter{
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                VStack{
                    TextField("Search...", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    List(filteredTools){tool in
                        HStack{
                            VStack(alignment: .leading){
                                Text(tool.name)
                                    .font(.headline)
                                Text(tool.description)
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                                Text("Price Per Day: \(tool.price)$")
                                    .foregroundColor(Color.red)
                                    .font(.caption)
                            }
                            Spacer()
                            
                            if tool.isAvailable{
                                Text("Available")
                                    .font(.caption)
                                    .foregroundColor(Color.green)
                            } else {
                                Text("Unavailable")
                                    .font(.caption)
                                    .foregroundColor(Color.red)
                            }
                            
                        }
                        
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    Search()
}
