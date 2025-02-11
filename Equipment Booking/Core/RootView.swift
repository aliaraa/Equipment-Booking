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
                    if #available(iOS 18.0, *) {
                        TabsView()
                    } else {
                        // Fallback on earlier versions
                    }
                }
            } else {
                NavigationStack {
                    UserAuthenticationView(showSignInView: .constant(false))
                        .environmentObject(authViewModel)
                }
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus() //Check authentication on loading

        }
        .environmentObject(authViewModel) // Provide auth state globally
    }

}


struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView()
        }
    }
}







