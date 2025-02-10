//
//  TabsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

import SwiftUI


@available(iOS 18.0, *)

struct TabsView: View {
    
    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                Search()
            }
            Tab("Cart", systemImage: "cart") {
                CartView()
            }
            Tab("Status", systemImage: "person.crop.circle") {
                UserProfileView()
                // UserAuthenticationView()
            
                
            }
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        TabsView()
            .environmentObject(CartManager())
    }
}
