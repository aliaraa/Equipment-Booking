//
//  UserProfileView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/18/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var selectedTab: String?
    
    @State private var showingEditProfile = false
    @State private var showingContactUs = false
    @State private var showingPrivacyPolicy = false
    @State private var showingRentals = false
    
    private var greeting: String {
        if let firstName = viewModel.user?.firstName, !firstName.isEmpty {
            return "Welcome, \(firstName)"
        } else if let email = viewModel.user?.email, let prefix = email.split(separator: "@").first {
            return "Welcome, \(prefix)"
        } else {
            return "Welcome, User"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Profilheader med gradientbakgrund
                ZStack {
                    GradientBackground()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 0) {
                        AsyncImage(url: URL(string: viewModel.user?.photoUrl ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Text(greeting)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if viewModel.authUser != nil {
                            Button(action: { showingEditProfile = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Edit Profile")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                // Meny (utan gradient, bara vit bakgrund)
                ScrollView {
                    VStack(spacing: 20) {
                        Section(header: Text("Your Account")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading) // Flytta till vänster
                            .padding(.top, 10)
                        ) {
                            ProfileMenuItem(icon: "list.bullet", text: "My Rentals") {
                                showingRentals = true
                            }
                            ProfileMenuItem(icon: "key.fill", text: "Reset Password") {
                                resetPassword()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Section(header: Text("Support & Info")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading) // Flytta till vänster
                        ) {
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
                .background(Color(.systemBackground))
                
                // Logga ut-knapp (på vit bakgrund)
                if viewModel.authUser != nil {
                    Button(action: signOut) {
                        Text("Log Out")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if selectedTab != nil {
                            selectedTab = "search"
                        }
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $showingEditProfile) { UserProfileEditView() }
            .navigationDestination(isPresented: $showingContactUs) { ContactUsView() }
            .navigationDestination(isPresented: $showingPrivacyPolicy) { PrivacyPolicyView() }
            .navigationDestination(isPresented: $showingRentals) { UserRentalsView() }
            .task { await viewModel.loadCurrentUser() }
            .background(Color(.systemBackground))
        }
        .environmentObject(authViewModel)
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
                authViewModel.checkAuthenticationStatus()
                dismiss()
            } catch {
                print("Sign-out failed: \(error.localizedDescription)")
            }
        }
    }
}

// Gradientbakgrund bara för headern
struct GradientBackground: View {
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.2),
                    Color.blue.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .medium))
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)
        }
    }
}

#Preview {
    UserProfileView(selectedTab: .constant(nil))
        .environmentObject(CartManager())
        .environmentObject(AuthenticationViewModel())
}
