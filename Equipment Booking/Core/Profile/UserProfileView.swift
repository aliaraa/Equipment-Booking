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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Shared auth state
    @Binding var selectedTab: String? // Optional binding, nil when not in TabsView
    
    @State private var showingEditProfile = false
    @State private var showingContactUs = false
    @State private var showingPrivacyPolicy = false
    @State private var showingRentals = false
    
    private var greeting: String {
        if let firstName = viewModel.user?.firstName, !firstName.isEmpty {
            return "Welcome \(firstName)"
        } else if let email = viewModel.user?.email, let prefix = email.split(separator: "@").first {
            return "Welcome \(prefix)"
        } else {
            return "Welcome User"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    AsyncImage(url: URL(string: viewModel.user?.photoUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                    }
                    
                    Text(greeting)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if viewModel.authUser != nil {
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                
                ScrollView {
                    VStack(spacing: 20) {
                        Section(header: Text("Your Account").font(.headline).padding(.top, 10)) {
                            ProfileMenuItem(icon: "list.bullet", text: "My Rentals") {
                                showingRentals = true
                            }
                            ProfileMenuItem(icon: "key.fill", text: "Reset Password") {
                                resetPassword()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Section(header: Text("Support & Info").font(.headline)) {
                            ProfileMenuItem(icon: "envelope", text: "Contact Us") {
                                showingContactUs = true
                            }
                            ProfileMenuItem(icon: "doc.text", text: "Privacy & Policy") {
                                showingPrivacyPolicy = true
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                if viewModel.authUser != nil {
                    Button(action: signOut) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if selectedTab != nil {
                            selectedTab = "search" // Switch to Search tab if in TabsView
                        }
                        dismiss() // Dismiss to previous context
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .navigationDestination(isPresented: $showingEditProfile) { UserProfileEditView() }
            .navigationDestination(isPresented: $showingContactUs) { ContactUsView() }
            .navigationDestination(isPresented: $showingPrivacyPolicy) { PrivacyPolicyView() }
            .navigationDestination(isPresented: $showingRentals) { UserRentalsView() }
            .task { await viewModel.loadCurrentUser() }
        }
        .environmentObject(authViewModel) // Ensure authViewModel is passed down
    }
    
    private func resetPassword() {
        guard let email = viewModel.user?.email else { print("Email not available"); return }
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: email)
                print("Password reset email sent to \(email)")
            } catch {
                print("Failed to send reset email: \(error.localizedDescription)")
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try AuthenticationManager.shared.signOut()
                authViewModel.checkAuthenticationStatus() // Force update auth state
                dismiss() // Dismiss view
            } catch {
                print("Sign-out failed: \(error.localizedDescription)")
            }
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
    UserProfileView(selectedTab: .constant(nil))
        .environmentObject(CartManager())
        .environmentObject(AuthenticationViewModel()) // Add for preview
}
