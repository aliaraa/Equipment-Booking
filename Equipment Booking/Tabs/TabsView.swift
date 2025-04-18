//
//  TabsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

// Changes: Updated cart icon to show item count

import SwiftUI

import SwiftUI

struct TabsView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @Binding var selectedTab: String?
    
    init(selectedTab: Binding<String?>) {
        self._selectedTab = selectedTab
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                Search()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag("search" as String?)
            
            NavigationStack {
                CartView()
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
            }
            .badge(cartManager.cartItems.count)
            .tag("cart" as String?)
            
            NavigationStack {
                UserProfileView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Status", systemImage: "person.crop.circle")
            }
            .tag("status" as String?)
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar)
        .onAppear {
            print("TabsView appeared with selectedTab: \(selectedTab ?? "nil")")
            if selectedTab == nil || authViewModel.isAuthenticated {
                selectedTab = "search"
            }
        }
    }
}

#Preview {
    TabsView(selectedTab: .constant("search"))
        .environmentObject(AuthenticationViewModel())
        .environmentObject(CartManager())
        .environmentObject(UserProfileViewModel())
}

