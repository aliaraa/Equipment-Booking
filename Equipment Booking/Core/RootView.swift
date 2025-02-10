//
//  RootView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI


struct RootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                NavigationStack {
                    EquipmentListingView()
                }
            } else {
                NavigationStack {
                    UserAuthenticationView(showSignInView: .constant(false))
                        .environmentObject(authViewModel)
                }
            }
        }
        .onAppear {
            // Check authentication status on app launch
            checkAuthenticationStatus()
        }
        .environmentObject(authViewModel) // Provide auth state globally
    }

    private func checkAuthenticationStatus() {
        do {
            let _ = try AuthenticationManager.shared.getAuthenticatedUser()
            authViewModel.isAuthenticated = true
        } catch {
            authViewModel.isAuthenticated = false
        }
    }
}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView()
        }
    }
}







