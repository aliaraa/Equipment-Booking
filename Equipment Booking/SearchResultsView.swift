//
//  SearchResultsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct SearchResultsView: View {
    
    var tools: [Tool]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                List(tools) { tool in
                    VStack(alignment: .leading) {
                        Text(tool.name)
                            .font(.headline)
                        Text(tool.description)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        Text("Price per day: \(tool.price)$")
                            .foregroundColor(Color.red)
                            .font(.caption)
                        if tool.isAvailable {
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
                .navigationTitle("Search Results")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    Search()
        .environmentObject(CartManager())
}
