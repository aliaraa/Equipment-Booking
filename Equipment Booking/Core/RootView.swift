//
//  RootView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI


struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedTab: String? = "search"
    @State private var showSignIn: Bool = false

    var body: some View {
        TabsView(selectedTab: $selectedTab)
            .environmentObject(authViewModel)
            .environmentObject(userProfileViewModel)
            .environmentObject(cartManager)
            .environment(\.showSignIn, $showSignIn)
            .sheet(isPresented: $showSignIn) {
                UserAuthenticationView(showSignInView: $showSignIn)
                    .environmentObject(authViewModel)
                    .environmentObject(userProfileViewModel)
                    .environmentObject(cartManager)
            }
            .onChange(of: authViewModel.isAuthenticated) { newValue in
                cartManager.isReadOnly = !newValue
                // NEW: Reset selectedTab to "search" after authentication change
                if newValue {
                    selectedTab = "search"
                    print("RootView: User authenticated, selectedTab set to \(selectedTab ?? "nil")")
                }
            }
    }
}

struct ShowSignInKey: EnvironmentKey {
    static let defaultValue: Binding<Bool>? = nil
}

extension EnvironmentValues {
    var showSignIn: Binding<Bool>? {
        get { self[ShowSignInKey.self] }
        set { self[ShowSignInKey.self] = newValue }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
            .environmentObject(CartManager())
    }
}

//struct RootView: View {
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
//    @EnvironmentObject var userProfileViewModel: UserProfileViewModel
//    @EnvironmentObject var cartManager: CartManager
//    @State private var selectedTab: String? = "search"
//    // NEW: State to control authentication prompt
//    @State private var showSignIn: Bool = false
//
//    var body: some View {
//        // MODIFIED: Always show TabsView, regardless of authentication status
//        TabsView(selectedTab: $selectedTab)
//            .environmentObject(authViewModel)
//            .environmentObject(userProfileViewModel)
//            // MODIFIED: Initialize CartManager with isReadOnly based on authentication status
//            .environmentObject(CartManager(isReadOnly: !authViewModel.isAuthenticated))
//            // NEW: Present authentication sheet when prompted
//            .sheet(isPresented: $showSignIn) {
//                UserAuthenticationView(showSignInView: $showSignIn)
//                    .environmentObject(authViewModel)
//                    .environmentObject(userProfileViewModel)
//                    .environmentObject(cartManager)
//            }
//            // NEW: Pass showSignIn to TabsView to allow child views to trigger authentication
//            .environment(\.showSignIn, $showSignIn)
//            .onChange(of: authViewModel.isAuthenticated) { newValue in
//                // NEW: Update CartManager's read-only status when authentication changes
//                cartManager.isReadOnly = !newValue
//            }
//    }
//}
//
//// NEW: Environment key to pass showSignIn binding to child views
//struct ShowSignInKey: EnvironmentKey {
//    static let defaultValue: Binding<Bool>? = nil
//}
//
//extension EnvironmentValues {
//    var showSignIn: Binding<Bool>? {
//        get { self[ShowSignInKey.self] }
//        set { self[ShowSignInKey.self] = newValue }
//    }
//}
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView()
//            .environmentObject(AuthenticationViewModel())
//            .environmentObject(UserProfileViewModel())
//            .environmentObject(CartManager())
//    }
//}
