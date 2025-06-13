//
//  TabsView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

// Changes: Updated cart icon to show item count

import SwiftUI
// hides cart tab for unregistered/unsigned users

struct TabsView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @Environment(\.showSignIn) var showSignIn
    @Binding var selectedTab: String?
    @State private var showStatusAlert: Bool = false // NEW: For Status tab alert
    
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
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newTab in
                if newTab == "status" && !authViewModel.isAuthenticated {
                    showStatusAlert = true
                    selectedTab = "search"
                } else {
                    selectedTab = newTab
                }
            }
        )) {
            // Search tab (always visible)
            NavigationStack {
                Search()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag("search" as String?)
            
            // Cart Tab (Visible for All)
            NavigationStack {
                if authViewModel.isAuthenticated {
                    CartView()
                } else {
                    Text("Please sign in to view your cart")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
                    .opacity(authViewModel.isAuthenticated ? 1.0 : 0.5) // Grey out for unauthenticated
            }
            .badge(cartManager.cartItems.count)
            .tag("cart" as String?)
            
            // Status tab (always visible)
            NavigationStack {
                if authViewModel.isAuthenticated {
                    UserProfileView(selectedTab: $selectedTab)
                } else {
                    // Placeholder to avoid empty view (not visible due to alert)
                    Text("Please sign in to view your profile")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .tabItem {
                Label("Status", systemImage: "person.crop.circle")
                    // NEW: Optional grey-out for unauthenticated users
                    .opacity(authViewModel.isAuthenticated ? 1.0 : 0.5)
            }
            .tag("status" as String?)
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar)
        .alert("Sign In Required", isPresented: $showStatusAlert) {
            Button("Sign In") {
                showSignIn?.wrappedValue = true
            }
            Button("Cancel", role: .cancel) {
                showStatusAlert = false
            }
        } message: {
            Text("You need to sign in or register to view your profile.")
        }
        .onAppear {
            print("TabsView appeared with selectedTab: \(selectedTab ?? "nil")")
            if selectedTab == nil {
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

//struct TabsView: View {
//    @EnvironmentObject private var authViewModel: AuthenticationViewModel
//    @EnvironmentObject var cartManager: CartManager
//    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
//    @Environment(\.showSignIn) var showSignIn // NEW: Access showSignIn binding
//    @Binding var selectedTab: String?
//    @State private var showSignInAlert: Bool = false // NEW: State for sign-in alert
//    
//    init(selectedTab: Binding<String?>) {
//        self._selectedTab = selectedTab
//        let appearance = UITabBarAppearance()
//        appearance.configureWithDefaultBackground()
//        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.3)
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
//    
//    var body: some View {
//        TabView(selection: Binding(
//            get: { selectedTab },
//            set: { newTab in
//                // NEW: Intercept cart tab selection for unauthenticated users
//                if newTab == "cart" && !authViewModel.isAuthenticated {
//                    showSignInAlert = true
//                } else {
//                    selectedTab = newTab
//                }
//            }
//        )) {
//            NavigationStack {
//                Search()
//            }
//            .tabItem {
//                Label("Search", systemImage: "magnifyingglass")
//            }
//            .tag("search" as String?)
//            
//            NavigationStack {
//                // MODIFIED: Conditional navigation for cart tab
//                if authViewModel.isAuthenticated {
//                    CartView()
//                } else {
//                    // Placeholder view (not shown due to alert)
//                    Text("Please sign in to view your cart")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                        .padding()
//                }
//            }
//            .tabItem {
//                Label("Cart", systemImage: "cart")
//            }
//            .badge(cartManager.cartItems.count)
//            .tag("cart" as String?)
//            
//            NavigationStack {
//                if authViewModel.isAuthenticated {
//                    UserProfileView(selectedTab: $selectedTab)
//                } else {
//                    UserAuthenticationView(showSignInView: .constant(true))
//                }
//            }
//            .tabItem {
//                Label("Status", systemImage: "person.crop.circle")
//            }
//            .tag("status" as String?)
//        }
//        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
//        .toolbarBackground(.visible, for: .tabBar)
//        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar)
//        // NEW: Alert for unauthenticated cart access
//        .alert("Sign In Required", isPresented: $showSignInAlert) {
//            Button("Sign In") {
//                showSignIn?.wrappedValue = true
//            }
//            Button("Cancel", role: .cancel) {
//                selectedTab = "search" // Redirect to search tab
//            }
//        } message: {
//            Text("You need to sign in or register to view your cart.")
//        }
//        .onAppear {
//            print("TabsView appeared with selectedTab: \(selectedTab ?? "nil")")
//            if selectedTab == nil {
//                selectedTab = "search"
//            }
//        }
//    }
//}
//
//#Preview {
//    TabsView(selectedTab: .constant("search"))
//        .environmentObject(AuthenticationViewModel())
//        .environmentObject(CartManager())
//        .environmentObject(UserProfileViewModel())
//}
