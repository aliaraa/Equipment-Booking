//
//  UserSettingsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI



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
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
                        
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
                
            }
            
            
        }
        
        .onAppear{
            viewModel.loadAuthProviders()
            viewModel.loadauthUser()
        }
        
        
        .navigationBarTitle("User Settings")
        
    }
}


struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationStack{
            UserSettingsView (showSignInView: .constant(false))
        }
    }
}

extension UserSettingsView{
    private var emailSection: some View{
        Section {
            Button("Reset Password"){
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESSET")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
            Button("Update Password"){
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD UPDATED")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
            
            Button("Update email"){
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("EMAIL UPDATED")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
        } header: {
            Text ("User Reset Functions")
        }
    }
    
    private var anonymousSection: some View{
        Section {
            Button("Link Google Account"){
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
            /*
            Button("Link Apple Account"){
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
            */
            
            Button("Link Email Account"){
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED")
                    }
                    catch{
                        print(error)
                        
                    }
                }
            }
        } header: {
            Text ("Create Account")
        }
    }
    
}

