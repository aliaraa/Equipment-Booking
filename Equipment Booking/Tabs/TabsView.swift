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
    @EnvironmentObject private var authViewModel: AuthenticationViewModel // Use environment object
    @EnvironmentObject var cartManager: CartManager
    @Binding var selectedTab: String? // Changed to Binding from RootView
    
    init(selectedTab: Binding<String?>) {
        self._selectedTab = selectedTab
        // Customize UITabBar appearance
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
        // SwiftUI tab bar enhancements
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar)
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        TabsView(selectedTab: .constant("search"))
            .environmentObject(AuthenticationViewModel())
            .environmentObject(CartManager())
            .environmentObject(UserProfileViewModel())
    } else {
        // Fallback on earlier versions
    }
}


//import SwiftUI
//
//@available(iOS 18.0, *)
//
//
//
//struct TabsView: View {
//    @StateObject private var authViewModel = AuthenticationViewModel()
//    @EnvironmentObject var cartManager: CartManager
//    @State private var selectedTab: String?
//    
//    init(selectedTab: String = "search") {
//        self._selectedTab = State(initialValue: selectedTab)
//        // Anpassa UITabBar-bakgrunden
//        let appearance = UITabBarAppearance()
//        appearance.configureWithDefaultBackground() // Standardbakgrund istället för helt transparent
//        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // Suddig effekt
//        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.3) // Lätt vit ton för mindre genomskinlighet
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            NavigationStack {
//                Search()
//            }
//            .tabItem {
//                Label("Search", systemImage: "magnifyingglass")
//            }
//            .tag("search")
//            
//            NavigationStack {
//                CartView()
//            }
//            .tabItem {
//                Label("Cart", systemImage: "cart")
//            }
//            .badge(cartManager.cartItems.count)
//            .tag("cart")
//            
//            NavigationStack {
//                if authViewModel.isAuthenticated {
//                    UserProfileView(selectedTab: $selectedTab)
//                } else {
//                    UserAuthenticationView(showSignInView: .constant(false))
//                }
//            }
//            .tabItem {
//                Label("Status", systemImage: "person.crop.circle")
//            }
//            .tag("status")
//        }
//        .onAppear {
//            authViewModel.checkAuthenticationStatus()
//        }
//        // Förstärk med SwiftUI
//        .toolbarBackground(.ultraThinMaterial, for: .tabBar) // Suddig effekt i SwiftUI
//        .toolbarBackground(.visible, for: .tabBar)
//        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar) // Lätt vit ton för att minska genomskinlighet
//    }
//}
//

