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
    
    var body: some View {
        if authViewModel.isAuthenticated {
            TabsView(selectedTab: $selectedTab)
                .environmentObject(authViewModel)
                .environmentObject(userProfileViewModel)
                .environmentObject(cartManager)
        } else {
            UserAuthenticationView(showSignInView: .constant(true))
                .environmentObject(authViewModel)
                .environmentObject(userProfileViewModel)
                .environmentObject(cartManager)
        }
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

