//
//  RootView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = true // Reset to false when userAuthenticationView is dismissed
    
    
    var body: some View {
        ZStack{
            if !showSignInView{
                NavigationStack {
                    EquipmentListingView() //Navigate to EquipmentListingView
                    // ProfileView(showSignInView: $showSignInView)
                    //UserSettingsView(showSignInView: $showSignInView)
                }
                
            }
            
            
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
        }
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack{
                UserAuthenticationView (showSignInView: $showSignInView)
            }
        }
        
        
        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                RootView ()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
