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


//struct RootView: View {
//    @State private var showSignInView: Bool = false
//    @State private var showAlreadySignedInAlert: Bool = false
//    @StateObject private var authViewModel = AuthenticationViewModel() // ✅ Ensure this is the shared instance
//
//    var body: some View {
//        ZStack {
//            if authViewModel.isAuthenticated {
//                NavigationStack {
//                    EquipmentListingView()
//                }
//                .alert("You are already signed in!", isPresented: $showAlreadySignedInAlert) {
//                    Button("OK", role: .cancel) { }
//                }
//            } else {
//                UserAuthenticationView(showSignInView: $showSignInView)
//                    .environmentObject(authViewModel) // ✅ Inject authentication state
//            }
//        }
//        .onAppear {
//            checkAuthenticationStatus()
//        }
//        .environmentObject(authViewModel) // ✅ Ensure auth state is globally available
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationStack {
//                UserAuthenticationView(showSignInView: $showSignInView)
//                    .environmentObject(authViewModel) // ✅ Inject authentication state
//            }
//        }
//    }
//
//    /// ✅ Check if the user is signed in when the app starts
//    private func checkAuthenticationStatus() {
//        do {
//            let _ = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignInView = false
//            self.showAlreadySignedInAlert = true
//            self.authViewModel.isAuthenticated = true
//        } catch {
//            self.showSignInView = true
//            self.authViewModel.isAuthenticated = false
//            print("Error checking authentication status: \(error)")
//        }
//    }
//}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView()
        }
    }
}




//import SwiftUI
//
//struct RootView: View {
//    @State private var showSignInView: Bool = false
//    @State private var showAlreadySignedInAlert: Bool = false
//    @StateObject private var authViewModel = AuthenticationViewModel()  // ✅ Initialize as a shared instance
//
//    var body: some View {
//        ZStack {
//            // Show EquipmentListingView if user is authenticated
//            if !showSignInView {
//                NavigationStack {
//                    EquipmentListingView()
//                }
//                .alert("You are already signed in!", isPresented: $showAlreadySignedInAlert) {
//                    Button("OK", role: .cancel) { }
//                }
//            }
//        }
//        .onAppear {
//            checkAuthenticationStatus()
//        }
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationStack {
//                UserAuthenticationView(showSignInView: $showSignInView)
//            }
//        }
//    }
//
//    private func checkAuthenticationStatus() {
//        do {
//            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignInView = false
//            self.showAlreadySignedInAlert = true // Show notification if already signed in
//        } catch {
//            self.showSignInView = true
//            print("Error checking authentication status: \(error)")
//        }
//    }
//}
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            RootView()
//        }
//    }
//}


//import SwiftUI
//
//struct RootView: View {
//    @State private var showSignInView: Bool = false // Initially false, will toggle based on user authentication
//
//    var body: some View {
//        ZStack {
//            // Show EquipmentListingView if the user is authenticated
//            if !showSignInView {
//                NavigationStack {
//                    EquipmentListingView()
//                }
//            }
//        }
//        .onAppear {
//            
//            checkAuthenticationStatus()
//            
//        }
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationStack {
//                UserAuthenticationView(showSignInView: $showSignInView)
//            }
//        }
//    }
//
//    private func checkAuthenticationStatus() {
//        do {
//            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignInView = false // Authenticated user found, proceed to main view
//        } catch {
//            self.showSignInView = true // Show sign-in view if there's an error or no user is authenticated
//            print("Error checking authentication status: \(error)")
//        }
//    }
//}
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            RootView()
//        }
//    }
//}






//import SwiftUI
//
//struct RootView: View {
//    
//    @State private var showSignInView: Bool = false // Always show UserAuthenticationView on start
//    @State private var showSignUpView: Bool = true // SignUp off at start
//    
//    var body: some View {
//        ZStack{
//            if !showSignInView  { //&& showSignUpView
//                NavigationStack {
//                    EquipmentListingView() //Navigate to EquipmentListingView
//
//                }
//                
//            }
//            
//        }
//        
//        .onAppear{
//            
//            showSignInView = true
//            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignInView = authUser == nil
//        }
//        
//        .fullScreenCover(isPresented: $showSignInView){
//            NavigationStack{
//                UserAuthenticationView (showSignInView: $showSignInView, showSignUpView: $showSignUpView)
//            }
//        }
//        
//        .fullScreenCover(isPresented: $showSignUpView){
//            NavigationStack{
//                SignUpView()
//            }
//        }
//        
//        
//    }
//}
//
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            RootView()
//        }
//    }
//}

//import SwiftUI
//
//struct RootView: View {
//    @State private var showSignInView: Bool = false // Initially false, will toggle based on user authentication
//
//    var body: some View {
//        ZStack {
//            // Show EquipmentListingView if the user is authenticated
//            if !showSignInView {
//                NavigationStack {
//                    EquipmentListingView()
//                }
//            }
//        }
//        .onAppear {
//            checkAuthenticationStatus()
//        }
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationStack {
//                UserAuthenticationView(showSignInView: $showSignInView)
//            }
//        }
//    }
//
//    private func checkAuthenticationStatus() {
//        let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//        self.showSignInView = authUser == nil // Show sign-in view if no authenticated user is found
//    }
//}


//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            RootView()
//        }
//    }
//}

