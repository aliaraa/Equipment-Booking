//
//  TabsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

// Changes: Updated cart icon to show item count

import SwiftUI

@available(iOS 18.0, *)
struct TabsView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedTab: String
    
    init(selectedTab: String = "search") {
        self._selectedTab = State(initialValue: selectedTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Search", systemImage: "magnifyingglass", value: "search") {
                Search()
            }
            
            Tab("Cart", systemImage: "cart", value: "cart") {
                CartView()
            }
            .badge(cartManager.cartItems.count)
            
            Tab("Status", systemImage: "person.crop.circle", value: "status") {
                NavigationStack {
                    if authViewModel.isAuthenticated {
                        UserProfileView(selectedTab: Binding(
                            get: { selectedTab },
                            set: { selectedTab = $0 ?? "search" }
                        ))
                    } else {
                        UserAuthenticationView(showSignInView: .constant(false))
                    }
                }
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}



