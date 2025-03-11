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
    @State private var selectedTab: String // ✅ Use String for tab identifiers
    
    init(selectedTab: String = "search") { // ✅ Default to "search"
        self._selectedTab = State(initialValue: selectedTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Search", systemImage: "magnifyingglass", value: "search") { // ✅ Use value instead of tag
                Search()
            }
            
            Tab("Cart", systemImage: "cart", value: "cart") { // ✅ Use value instead of tag
                CartView()
            }
            .badge(cartManager.cartItems.count)
            
            Tab("Status", systemImage: "person.crop.circle", value: "status") { // ✅ Use value instead of tag
                NavigationStack {
                    if authViewModel.isAuthenticated {
                        UserProfileView()
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

#Preview {
    if #available(iOS 18.0, *) {
        TabsView()
            .environmentObject(CartManager())
    } else {
        Text("iOS 18.0+ required")
    }
}


//@available(iOS 18.0, *)
//struct TabsView: View {
//    @StateObject private var authViewModel = AuthenticationViewModel()
//    @EnvironmentObject var cartManager: CartManager
//    
//    var body: some View {
//        TabView {
//            Tab("Search", systemImage: "magnifyingglass") {
//                Search()
//            }
//            
//            Tab("Cart", systemImage: "cart") {
//                CartView()
//            }
//            .badge(cartManager.cartItems.count)
//            
//            Tab("Status", systemImage: "person.crop.circle") {
//                NavigationStack {
//                    if authViewModel.isAuthenticated {
//                        UserProfileView()
//                    } else {
//                        UserAuthenticationView(showSignInView: .constant(false))
//                    }
//                }
//            }
//        }
//        .onAppear {
//            authViewModel.checkAuthenticationStatus()
//        }
//    }
//}
//
//#Preview {
//    if #available(iOS 18.0, *) {
//        TabsView()
//            .environmentObject(CartManager())
//    } else {
//        Text("iOS 18.0+ required")
//    }
//}

