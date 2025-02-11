//
//  UserProfileView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/18/25.
//
// UserProfileView

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingSignIn = false  // Controls sign-out navigation
    @State private var isShowingSettings = false // Controls settings navigation
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = viewModel.user {
                    // Profile Image
                    AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
                        image.resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.top)
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                            .padding(.top)
                    }
                    
                    // Display user's name or email
                    Text(user.firstName ?? user.email ?? "Anonymous User")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Divider().padding(.vertical)
                    
                    // Profile Menu Items
                    VStack(spacing: 15) {
                        ProfileMenuItem(icon: "list.bullet.rectangle", text: "My Rentals") {
                            print("My Rentals tapped")
                        }
                        
                        // ✅ Open Settings using `.sheet()`
                        ProfileMenuItem(icon: "gearshape", text: "Settings") {
                            isShowingSettings = true
                        }
                        
                        ProfileMenuItem(icon: "phone.fill", text: "Contact Us") {
                            print("Support tapped")
                        }
                        
                        ProfileMenuItem(icon: "doc.text.fill", text: "Privacy & Policy") {
                            print("Privacy & Policy tapped")
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    ProgressView("Loading user data...")
                        .task {
                            await viewModel.loadCurrentUser()
                        }
                }
                
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
                .padding(.horizontal, 20)
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
        }
        // ✅ Present User Settings as a sheet
        .sheet(isPresented: $isShowingSettings) {
            UserSettingsView(isShowingSignIn: $isShowingSignIn)
        }
        // ✅ Navigate to Sign-in upon logout
        .navigationDestination(isPresented: $isShowingSignIn) {
            UserAuthenticationView(showSignInView: $isShowingSignIn)
        }
    }
}

// ✅ Reusable Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let text: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.headline)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black)
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
    UserProfileView()
}






