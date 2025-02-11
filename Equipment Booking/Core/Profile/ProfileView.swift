//
//  ProfileView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/29/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    // Loads the authenticated user from Firebase.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
    }
    
    // Toggles the admin status of the user.
    func toggleAdminStatus() {
        guard let user else { return }
        let currentValue = user.isAdmin ?? false
        
        Task {
            try await UserManager.shared.updateUserAdminStatus(userId: user.userId, isAdmin: !currentValue)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var isShowingSettings = false // ✅ Controls Settings navigation
    
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
                    
                    // Display user's ID
                    Text("User ID: \(user.userId)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider().padding(.vertical)
                    
                    // Profile Information
                    VStack(spacing: 15) {
                        if let isAnonymous = user.isAnonymous {
                            ProfileMenuItem(icon: "person.fill.questionmark", text: "Is Anonymous: \(isAnonymous.description.capitalized)")
                        }
                        
                        Button {
                            viewModel.toggleAdminStatus()
                        } label: {
                            ProfileMenuItem(icon: "person.fill.checkmark", text: "User is Admin: \((user.isAdmin ?? false).description.capitalized)")
                        }
                        
                        // ✅ Open Settings using `.sheet()`
                        ProfileMenuItem(icon: "gearshape", text: "Settings") {
                            isShowingSettings = true
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    ProgressView("Loading profile...")
                        .task {
                            try? await viewModel.loadCurrentUser()
                        }
                }
                
                Spacer()
                
                // Equipment Listing Navigation Button
                NavigationLink(destination: EquipmentListingView()) {
                    Text("Go to Equipment Listing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .toolbar {
                // ✅ Settings Icon in Navigation Bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        // ✅ Present User Settings as a sheet
        .sheet(isPresented: $isShowingSettings) {
            UserSettingsView(isShowingSignIn: $showSignInView)
        }
    }
}



#Preview {
    ProfileView(showSignInView: .constant(false))
}
