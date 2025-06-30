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
        TabView(selection: Binding(
            get: { selectedTab },
            set: { selectedTab = $0 }
        )) {
            // Search tab (always visible)
            NavigationStack {
                Search()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
                    .font(Typography.body)
            }
            .tag("search" as String?)
            
            // Cart Tab (Visible for All)
            NavigationStack {
                if authViewModel.isAuthenticated {
                    CartView()
                } else {
                    VStack(spacing: 20) {
                        Text("Please sign in to view your cart")
                            .font(Typography.title)
                            .foregroundColor(.gray)
                        NavigationLink(destination: UserAuthenticationView()) {
                            Text("Sign In")
                                .font(Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
                    .font(Typography.body)
                    .opacity(authViewModel.isAuthenticated ? 1.0 : 0.5)
            }
            .badge(cartManager.cartItems.count)
            .tag("cart" as String?)
            
            // Status tab (always visible)
            NavigationStack {
                if authViewModel.isAuthenticated {
                    UserProfileView(selectedTab: $selectedTab)
                } else {
                    VStack(spacing: 20) {
                        Text("Please sign in to view your profile")
                            .font(Typography.title)
                            .foregroundColor(.gray)
                        NavigationLink(destination: UserAuthenticationView()) {
                            Text("Sign In")
                                .font(Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding()
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Account Status")
                                .font(Typography.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .tabItem {
                Label("Status", systemImage: "person.crop.circle")
                    .font(Typography.body)
                    .opacity(authViewModel.isAuthenticated ? 1.0 : 0.5)
            }
            .tag("status" as String?)
        }
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color.white.opacity(0.1), for: .tabBar)
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
