//
//  UserSettingsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//
// UserSettingsView

import SwiftUI
import FirebaseAuth

struct UserSettingsView: View {
    @StateObject private var viewModel = UserSettingsViewModel()
    @Binding var isShowingSignIn: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingProfileEdit = false // ✅ State for navigation

    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                if let user = viewModel.user {
                    // Profile Image & Name
//                    VStack(spacing: 10) {
                        AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
                            image.resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.yellow)
                        }
                        .padding(.top)

                        Text(user.firstName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
//                    }

                    Divider().padding(.vertical)

                    // Settings Options
                    VStack(spacing: 15) {
                        // ✅ Button to trigger navigation
                        SettingsMenuItem(icon: "pencil", text: "Update Profile") {
                            isShowingProfileEdit = true
                        }
                        
                        
                        SettingsMenuItem(icon: "key.fill", text: "Reset Password") {
                            resetPassword(for: user.email)
                        }
                        


//                        SettingsMenuItem(icon: "arrow.backward.square", text: "Sign Out", color: .red) {
//                            Task {
//                                do {
//                                    try AuthenticationManager.shared.signOut()
//                                    isShowingSignIn = true
//                                    presentationMode.wrappedValue.dismiss()
//                                } catch {
//                                    print("Sign-out failed: \(error.localizedDescription)")
//                                }
//                            }
//                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Logout Button
                    Button {
                        Task {
                            do {
                                try AuthenticationManager.shared.signOut()
                                isShowingSignIn = true // Navigate to sign-in
                            } catch {
                                print("Error during sign-out: \(error)")
                            }
                        }
                    } label: {
                        Text("Log out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    
                    
                } else {
                    ProgressView("Loading user settings...")
                        .task {
                            await viewModel.loadCurrentUser()
                        }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
            // ✅ Navigation Destination for Profile Edit
            .navigationDestination(isPresented: $isShowingProfileEdit) {
                UserProfileEditView()
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



//import SwiftUI
//import FirebaseAuth
//
//struct UserSettingsView: View {
//    @StateObject private var viewModel = UserSettingsViewModel()
//    @Binding var isShowingSignIn: Bool // Controls sign-out navigation
//    @Environment(\.presentationMode) var presentationMode // For back navigation
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if let user = viewModel.user {
//                    // Profile Image & Name
//                    VStack(spacing: 10) {
//                        AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                            image.resizable()
//                                .frame(width: 100, height: 100)
//                                .clipShape(Circle())
//                        } placeholder: {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.yellow)
//                        }
//                        .padding(.top)
//
//                        Text(user.firstName ?? "User")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                    }
//
//                    Divider()
//                        .padding(.vertical)
//
//                    // Settings Options
//                    VStack(spacing: 15) {
//                        SettingsMenuItem(icon: "key.fill", text: "Reset Password") {
//                            resetPassword(for: user.email)
//                        }
//                        
//                        NavigationLink(destination: UserProfileEditView()) {
//                            SettingsMenuItem(icon: "pencil", text: "Update Profile")
//                        }
//                        
//                        SettingsMenuItem(icon: "arrow.backward.square", text: "Sign Out", color: .red) {
//                            Task {
//                                do {
//                                    try AuthenticationManager.shared.signOut()
//                                    isShowingSignIn = true // Navigate back to login
//                                    presentationMode.wrappedValue.dismiss()
//                                } catch {
//                                    print("Sign-out failed: \(error.localizedDescription)")
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                } else {
//                    ProgressView("Loading user settings...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.headline)
//                            .foregroundColor(.yellow)
//                    }
//                }
//            }
//        }
//    }
//
//    private func resetPassword(for email: String?) {
//        guard let email = email else {
//            print("Email not available for password reset")
//            return
//        }
//        Task {
//            do {
//                try await AuthenticationManager.shared.resetPassword(email: email)
//                print("Password reset email sent to \(email)")
//            } catch {
//                print("Failed to send reset email: \(error.localizedDescription)")
//            }
//        }
//    }
//}

// ✅ Reusable Settings Menu Item
struct SettingsMenuItem: View {
    let icon: String
    let text: String
    var color: Color = .black
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.headline)
                Text(text)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
            .shadow(radius: 2)
        }
    }
}

#Preview {
    UserSettingsView(isShowingSignIn: .constant(false))
}


//import SwiftUI
//import FirebaseAuth
//
//struct UserSettingsView: View {
//    @StateObject private var viewModel = UserSettingsViewModel()
//    @Binding var showSignInView: Bool // Controls sign-out navigation
//    @Binding var navigateToSettings: Bool
//    @Environment(\.presentationMode) var presentationMode // For back navigation
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if let user = viewModel.user {
//                    // Profile Image & Name
//                    VStack(spacing: 10) {
//                        AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                            image.resizable()
//                                .frame(width: 100, height: 100)
//                                .clipShape(Circle())
//                        } placeholder: {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.yellow)
//                        }
//                        .padding(.top)
//
//                        Text(user.firstName ?? "User")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundColor(.black)
//                    }
//
//                    Divider()
//                        .padding(.vertical)
//
//                    // Settings Options
//                    VStack(spacing: 15) {
//                        SettingsMenuItem(icon: "key.fill", text: "Reset Password") {
//                            resetPassword(for: user.email)
//                        }
//                        
//                        NavigationLink(destination: UserProfileEditView()) {
//                            SettingsMenuItem(icon: "pencil", text: "Update Profile")
//                        }
//
//                        SettingsMenuItem(icon: "arrow.backward.square", text: "Sign Out", color: .red) {
//                            Task {
//                                do {
//                                    try AuthenticationManager.shared.signOut()
//                                    showSignInView = true // Navigate back to login
//                                } catch {
//                                    print("Sign-out failed: \(error.localizedDescription)")
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                } else {
//                    ProgressView("Loading user settings...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.headline)
//                            .foregroundColor(.yellow)
//                    }
//                }
//            }
//        }
//    }
//
//    private func resetPassword(for email: String?) {
//        guard let email = email else {
//            print("Email not available for password reset")
//            return
//        }
//        Task {
//            do {
//                try await AuthenticationManager.shared.resetPassword(email: email)
//                print("Password reset email sent to \(email)")
//            } catch {
//                print("Failed to send reset email: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// ✅ Reusable Settings Item (Same Look as Profile)
//struct SettingsMenuItem: View {
//    let icon: String
//    let text: String
//    var color: Color = .black
//    var action: (() -> Void)? = nil
//
//    var body: some View {
//        Button(action: { action?() }) {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.yellow)
//                    .font(.headline)
//                Text(text)
//                    .font(.headline)
//                    .foregroundColor(color)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
//            .shadow(radius: 2)
//        }
//    }
//}
//
//#Preview {
//    UserSettingsView(showSignInView: .constant(false), navigateToSettings: .constant(true))
//}


//import SwiftUI
//import FirebaseAuth
//
//struct UserSettingsView: View {
//    @StateObject private var viewModel = UserSettingsViewModel()
//    @Binding var showSignInView: Bool // To handle sign-out and navigation back
//    
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if let user = viewModel.user {
//                    // Profile Image and Welcome Message
//                    VStack(spacing: 10) {
//                        // Profile Image
//                        AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                            image.resizable()
//                                .frame(width: 100, height: 100)
//                                .clipShape(Circle())
//                        } placeholder: {
//                            Image(systemName: "person.crop.circle")
//                                .resizable()
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.top)
//
//                        // Welcome Text
//                        Text(" \(user.firstName ?? "User")")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .padding(.bottom, 20)
//                    }
//
//                    // Settings Buttons
//                    List {
//                        Section {
//                            Button("Reset Password") {
//                                resetPassword(for: user.email)
//                            }
//                            NavigationLink(destination: UserProfileEditView()) {
//                                Text("Update Profile")
//                            }
//                            
//                        }
//
//                        // Sign Out Button
//                        Section {
//                            Button {
//                                Task {
//                                    do {
//                                        try AuthenticationManager.shared.signOut()
//                                        showSignInView = true // Navigate back to sign-in
//                                    } catch {
//                                        print("Sign-out failed: \(error.localizedDescription)")
//                                    }
//                                }
//                            } label: {
//                                Text("Sign Out")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .frame(height: 55)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.orange)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                } else {
//                    // Loading State
//                    ProgressView("Loading user settings...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//            }
//            .navigationTitle("User Settings")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        showSignInView = false // Navigate back to main view
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.headline)
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//        }
//    }
//
//    private func resetPassword(for email: String?) {
//        guard let email = email else {
//            print("Email not available for password reset")
//            return
//        }
//        Task {
//            do {
//                try await AuthenticationManager.shared.resetPassword(email: email)
//                print("Password reset email sent to \(email)")
//            } catch {
//                print("Failed to send reset email: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//#Preview {
//    UserSettingsView(showSignInView: .constant(true))
//}



