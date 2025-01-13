//
//  RootView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = true // Always show UserAuthenticationView on start
    @State private var showSignUpView: Bool = false // SignUp off at start
    
    var body: some View {
        ZStack{
            if !showSignInView && showSignUpView {
                NavigationStack {
                    EquipmentListingView() //Navigate to EquipmentListingView
                    // ProfileView(showSignInView: $showSignInView)
                    //UserSettingsView(showSignInView: $showSignInView)
                }
                
            }
            
        }
        
        .onAppear{
            
            //   showSignInView = true
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack{
                UserAuthenticationView (showSignInView: $showSignInView, showSignUpView: $showSignUpView)
            }
        }
        
        .fullScreenCover(isPresented: $showSignUpView){
            NavigationStack{
                SignUpView()
            }
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
