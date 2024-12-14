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
    
    func resetPassword () async throws {
        let authUser =  try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
        
    }
    
    
    func updateEmail () async throws {
        let email = "test123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
        
    }
    
    func updatePassword () async throws {
        let password = "test123"
        try await AuthenticationManager.shared.updatePassword(password: password)
        
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
            emailUserResetSection
        
            .navigationBarTitle("User Settings")

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

extension UserSettingsView{
    private var emailUserResetSection: some View{
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
            Text ("User Reset Functions)"
                  }
            }
    }
}
