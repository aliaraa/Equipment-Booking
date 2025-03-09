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
//

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingSignIn = false
    @State private var isShowingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = viewModel.user {
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
                    
                    Text(user.firstName ?? user.email ?? "Anonymous User")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Divider().padding(.vertical)
                    
                    VStack(spacing: 15) {
                        // My Rentals with NavigationLink
                        NavigationLink(destination: UserRentalsView()) {
                            ProfileMenuItem(icon: "list.bullet.rectangle", text: "My Rentals", isNavigation: true)
                        }
                        
                        // Settings with action
                        ProfileMenuItem(icon: "gearshape", text: "Settings") {
                            isShowingSettings = true
                        }
                        
                        ProfileMenuItem(icon: "phone.fill", text: "Contact Us") {
                            print("Contact Us tapped")
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
                
                Button {
                    Task {
                        do {
                            try AuthenticationManager.shared.signOut()
                            isShowingSignIn = true
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
        .sheet(isPresented: $isShowingSettings) {
            UserSettingsView(isShowingSignIn: $isShowingSignIn)
        }
        .navigationDestination(isPresented: $isShowingSignIn) {
            UserAuthenticationView(showSignInView: $isShowingSignIn)
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let text: String
    var action: (() -> Void)? = nil
    var isNavigation: Bool = false
    
    var body: some View {
        let content = HStack {
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
        .contentShape(Rectangle())
        
        // Apply .onTapGesture only when not used for navigation
        if isNavigation {
            content // No gesture for NavigationLink
        } else {
            content
                .onTapGesture {
                    action?()
                }
        }
    }
}

#Preview {
    UserProfileView()
}
