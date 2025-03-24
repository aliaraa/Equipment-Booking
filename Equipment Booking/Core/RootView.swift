//
//  RootView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel() // for managing user profile data
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                if #available(iOS 18.0, *) {
                    TabsView()
                        .environmentObject(userProfileViewModel) // Pass to TabsView
                } else {
                    // Fallback on earlier versions
                }
            } else {
                NavigationStack {
                    UserAuthenticationView(showSignInView: .constant(false))
                }
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
            if authViewModel.isAuthenticated {
                Task {
                    await userProfileViewModel.loadCurrentUser() // Preload user and image
                }
            }
        }
        .environmentObject(authViewModel)
        .environmentObject(userProfileViewModel) // Provide user profile data globally
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView()
                .environmentObject(CartManager())
        }
    }
}


