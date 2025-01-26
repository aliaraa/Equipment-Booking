//
//  UserSettingsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI
import FirebaseAuth

struct UserSettingsView: View {
    @StateObject private var viewModel = UserSettingsViewModel()
    @Binding var showSignInView: Bool // To handle sign-out and navigation back

    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.user {
                    // Profile Image and Welcome Message
                    VStack(spacing: 10) {
                        // Profile Image
                        AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
                            image.resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)

                        // Welcome Text
                        Text(" \(user.firstName ?? "User")")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 20)
                    }

                    // Settings Buttons
                    List {
                        Section {
                            Button("Reset Password") {
                                resetPassword(for: user.email)
                            }
                            NavigationLink(destination: UserProfileEditView()) {
                                Text("Update Profile")
                            }
                            
                        }

                        // Sign Out Button
                        Section {
                            Button {
                                Task {
                                    do {
                                        try AuthenticationManager.shared.signOut()
                                        showSignInView = true // Navigate back to sign-in
                                    } catch {
                                        print("Sign-out failed: \(error.localizedDescription)")
                                    }
                                }
                            } label: {
                                Text("Sign Out")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(height: 55)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // Loading State
                    ProgressView("Loading user settings...")
                        .task {
                            await viewModel.loadCurrentUser()
                        }
                }
            }
            .navigationTitle("User Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSignInView = false // Navigate back to main view
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    private func resetPassword(for email: String?) {
        guard let email = email else {
            print("Email not available for password reset")
            return
        }
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: email)
                print("Password reset email sent to \(email)")
            } catch {
                print("Failed to send reset email: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    UserSettingsView(showSignInView: .constant(false))
}


#Preview {
    UserSettingsView(showSignInView: .constant(false))
}


// Old UserSettingsView
//struct UserSettingsView: View {
//    
//    @StateObject private var viewModel = UserSettingsViewModel()
//    @Binding var showSignInView: Bool
//    
//    var body: some View {
//        List{
//            Button("Log out"){
//                Task {
//                    do {
//                        try viewModel.signOut()
//                        showSignInView = true
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//            
//            if viewModel.authProviders.contains(.email) {
//                emailSection
//            }
//            
//                        
//            if viewModel.authUser?.isAnonymous == true {
//                anonymousSection
//                
//            }
//            
//            
//        }
//        
//        .onAppear{
//            viewModel.loadAuthProviders()
//            viewModel.loadauthUser()
//        }
//        
//        
//        .navigationBarTitle("User Settings")
//        
//    }
//}
//
//
//struct UserSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        NavigationStack{
//            UserSettingsView (showSignInView: .constant(false))
//        }
//    }
//}
//
//extension UserSettingsView{
//    private var emailSection: some View{
//        Section {
//            Button("Reset Password"){
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        print("PASSWORD RESSET")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//            Button("Update Password"){
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        print("PASSWORD UPDATED")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//            
//            Button("Update email"){
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        print("EMAIL UPDATED")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//        } header: {
//            Text ("User Reset Functions")
//        }
//    }
//    
//    private var anonymousSection: some View{
//        Section {
//            Button("Link Google Account"){
//                Task {
//                    do {
//                        try await viewModel.linkGoogleAccount()
//                        print("GOOGLE LINKED")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//            /*
//            Button("Link Apple Account"){
//                Task {
//                    do {
//                        try await viewModel.linkAppleAccount()
//                        print("APPLE LINKED")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//            */
//            
//            Button("Link Email Account"){
//                Task {
//                    do {
//                        try await viewModel.linkEmailAccount()
//                        print("EMAIL LINKED")
//                    }
//                    catch{
//                        print(error)
//                        
//                    }
//                }
//            }
//        } header: {
//            Text ("Create Account")
//        }
//    }
//    
//}

