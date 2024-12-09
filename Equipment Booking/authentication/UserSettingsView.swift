//
//  UserSettingsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI

@MainActor

final class UserSettingsViewModel: ObservableObject {
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    } 
    
}

struct UserSettingsView: View {
    
    @StateObject private var viewModel = UserSettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List{
            Button("Log out"){
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
            .navigationBarTitle("Settings")

        }
    }
}
    
struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationStack{
            UserSettingsView (showSignInView: .constant(false))
        }
    }
}
