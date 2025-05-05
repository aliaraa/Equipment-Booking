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
    @EnvironmentObject private var viewModel: UserProfileViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: String?
    
    @State private var navigateToEditProfile = false
    @State private var navigateToContactUs = false
    @State private var navigateToPrivacyPolicy = false
    @State private var navigateToRentals = false
    @State private var navigateToNotifications = false
    @State private var showResetPasswordAlert = false
    @State private var resetPasswordMessage: String?
    @State private var hasLoaded: Bool = false
    
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
                if authViewModel.isAuthenticated {
                    ZStack {
                        GradientBackground()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(spacing: 0) {
                            if let photoUrl = viewModel.user?.photoUrl, !photoUrl.isEmpty {
                                // CHANGE: Use cached image if available
                                if let cachedImage = ProfileImageCache.shared.getImage(forKey: photoUrl) {
                                    Image(uiImage: cachedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                                        .shadow(color: .gray.opacity(0.2), radius: 2)
                                        .onAppear { print("Using cached image: \(photoUrl)") }
                                } else if let url = URL(string: photoUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .onAppear { print("AsyncImage loading: \(photoUrl)") }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                                                .shadow(color: .gray.opacity(0.2), radius: 2)
                                                .onAppear { print("AsyncImage loaded: \(photoUrl)") }
                                        case .failure(let error):
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.blue)
                                                .background(Color(.systemGray6))
                                                .clipShape(Circle())
                                                .onAppear { print("AsyncImage failed: \(photoUrl), error: \(error)") }
                                        @unknown default:
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.blue)
                                                .background(Color(.systemGray6))
                                                .clipShape(Circle())
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.blue)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                        .onAppear { print("Invalid photoUrl: \(photoUrl)") }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                    .onAppear { print("No photoUrl, using placeholder") }
                            }
                            
                            Text(greeting)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            if viewModel.authUser != nil {
                                Button(action: { navigateToEditProfile = true }) {
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
                                    .shadow(color: .blue.opacity(0.3), radius: 5)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Section(header: Text("Your Account")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                            ) {
                                NavigationLink(destination: UserRentalsView(), isActive: $navigateToRentals) {
                                    ProfileMenuItem(icon: "list.bullet", text: "My Rentals") {
                                        navigateToRentals = true
                                    }
                                }
                                ProfileMenuItem(icon: "key.fill", text: "Reset Password") {
                                    resetPassword()
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Section(header: Text("Support & Info")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ) {
                                NavigationLink(destination: ContactUsView(), isActive: $navigateToContactUs) {
                                    ProfileMenuItem(icon: "envelope", text: "Contact Us") {
                                        navigateToContactUs = true
                                    }
                                }
                                NavigationLink(destination: PrivacyPolicyView(), isActive: $navigateToPrivacyPolicy) {
                                    ProfileMenuItem(icon: "doc.text", text: "Privacy & Policy") {
                                        navigateToPrivacyPolicy = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .background(Color(.systemBackground))
                    
                    if viewModel.authUser != nil {
                        Button(action: signOut) {
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.2), radius: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color(.systemBackground))
                    }
                } else {
                    Color.clear
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if authViewModel.isAuthenticated {
                        Button(action: {
                            selectedTab = "search"
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if authViewModel.isAuthenticated {
                        NavigationLink(destination: NotificationsView(viewModel: viewModel), isActive: $navigateToNotifications) {
                            ZStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(viewModel.unreadCount > 0 ? .blue : .gray)
                                    .font(.system(size: 20))
                                if viewModel.unreadCount > 0 {
                                    Text("\(viewModel.unreadCount)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: UserProfileEditView()
                    .environmentObject(viewModel)
                    .environmentObject(cartManager)
                    .environmentObject(authViewModel)
                    .onDisappear {
                        Task { await viewModel.loadCurrentUser(forceServer: true) }
                    },
                    isActive: $navigateToEditProfile) { EmptyView() }
            )
            .onAppear {
                if !hasLoaded {
                    hasLoaded = true
                    Task {
                        await viewModel.loadCurrentUser(forceServer: true)
                    }
                        }
//                print("UserProfileView onAppear")
//                viewModel.loadCurrentUser(fetchServer: true)
                
            }
            .alert(isPresented: $showResetPasswordAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text(resetPasswordMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        signOut()
                    }
                )
            }
        }
    }
    
    private func resetPassword() {
        guard let email = viewModel.user?.email else {
            resetPasswordMessage = "Email not available"
            showResetPasswordAlert = true
            return
        }
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: email)
                resetPasswordMessage = "Password reset link sent to \(email)"
                showResetPasswordAlert = true
            } catch {
                resetPasswordMessage = "Failed to send reset email: \(error)"
                showResetPasswordAlert = true
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try AuthenticationManager.shared.signOut()
                authViewModel.checkAuthenticationStatus()
                selectedTab = "search"
                dismiss()
            } catch {
                print("Sign-out failed: \(error)")
            }
        }
    }
}

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

struct NotificationsView: View {
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .gray : .black)
                    Text(notification.body)
                        .font(.subheadline)
                    Text(notification.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    Task { await viewModel.markNotificationAsRead(id: notification.id, rentalId: notification.rentalId) }
                }
            }
        }
        .navigationTitle("Notifications")
    }
}

#Preview {
    UserProfileView(selectedTab: .constant(nil))
        .environmentObject(CartManager())
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
}

//struct UserProfileView: View {
//    @EnvironmentObject private var viewModel: UserProfileViewModel
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
//    @EnvironmentObject var cartManager: CartManager
//    @Environment(\.dismiss) var dismiss
//    @Binding var selectedTab: String?
//    
//    @State private var navigateToEditProfile = false
//    @State private var navigateToContactUs = false
//    @State private var navigateToPrivacyPolicy = false
//    @State private var navigateToRentals = false
//    @State private var navigateToNotifications = false
//    @State private var showResetPasswordAlert = false
//    @State private var resetPasswordMessage: String?
//    
//    private var greeting: String {
//        if let firstName = viewModel.user?.firstName, !firstName.isEmpty {
//            return "Welcome, \(firstName)"
//        } else if let email = viewModel.user?.email, let prefix = email.split(separator: "@").first {
//            return "Welcome, \(prefix)"
//        } else {
//            return "Welcome, User"
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                if authViewModel.isAuthenticated {
//                    ZStack {
//                        GradientBackground()
//                            .frame(height: 200)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                        
//                        VStack(spacing: 0) {
//                            if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
//                                AsyncImage(url: url) { phase in
//                                    switch phase {
//                                    case .empty:
//                                        ProgressView()
//                                            .onAppear { print("AsyncImage loading: \(photoUrl)") }
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 100, height: 100)
//                                            .clipShape(Circle())
//                                            .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
//                                            .shadow(color: .gray.opacity(0.2), radius: 2)
//                                            .onAppear { print("AsyncImage loaded: \(photoUrl)") }
//                                    case .failure(let error):
//                                        Image(systemName: "person.crop.circle.fill")
//                                            .resizable()
//                                            .frame(width: 100, height: 100)
//                                            .foregroundColor(.blue)
//                                            .background(Color(.systemGray6))
//                                            .clipShape(Circle())
//                                            .onAppear { print("AsyncImage failed: \(photoUrl), error: \(error)") }
//                                    @unknown default:
//                                        Image(systemName: "person.crop.circle.fill")
//                                            .resizable()
//                                            .frame(width: 100, height: 100)
//                                            .foregroundColor(.blue)
//                                            .background(Color(.systemGray6))
//                                            .clipShape(Circle())
//                                    }
//                                }
//                            } else {
//                                Image(systemName: "person.crop.circle.fill")
//                                    .resizable()
//                                    .frame(width: 100, height: 100)
//                                    .foregroundColor(.blue)
//                                    .background(Color(.systemGray6))
//                                    .clipShape(Circle())
//                                    .onAppear { print("No photoUrl, using placeholder") }
//                            }
//                            
//                            Text(greeting)
//                                .font(.system(size: 24, weight: .bold, design: .rounded))
//                                .foregroundColor(.primary)
//                            
//                            if viewModel.authUser != nil {
//                                Button(action: { navigateToEditProfile = true }) {
//                                    HStack(spacing: 8) {
//                                        Image(systemName: "pencil")
//                                            .font(.system(size: 16, weight: .semibold))
//                                        Text("Edit Profile")
//                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                    }
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 10)
//                                    .padding(.horizontal, 20)
//                                    .background(
//                                        LinearGradient(
//                                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
//                                            startPoint: .leading,
//                                            endPoint: .trailing
//                                        )
//                                    )
//                                    .cornerRadius(20)
//                                    .shadow(color: .blue.opacity(0.3), radius: 5)
//                                }
//                            }
//                        }
//                        .padding(.vertical, 20)
//                    }
//                    
//                    ScrollView {
//                        VStack(spacing: 20) {
//                            Section(header: Text("Your Account")
//                                .font(.system(size: 22, weight: .bold, design: .rounded))
//                                .foregroundColor(.primary)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.top, 10)
//                            ) {
//                                NavigationLink(destination: UserRentalsView(), isActive: $navigateToRentals) {
//                                    ProfileMenuItem(icon: "list.bullet", text: "My Rentals") {
//                                        navigateToRentals = true
//                                    }
//                                }
//                                ProfileMenuItem(icon: "key.fill", text: "Reset Password") {
//                                    resetPassword()
//                                }
//                            }
//                            .padding(.horizontal, 20)
//                            
//                            Section(header: Text("Support & Info")
//                                .font(.system(size: 22, weight: .bold, design: .rounded))
//                                .foregroundColor(.primary)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            ) {
//                                NavigationLink(destination: ContactUsView(), isActive: $navigateToContactUs) {
//                                    ProfileMenuItem(icon: "envelope", text: "Contact Us") {
//                                        navigateToContactUs = true
//                                    }
//                                }
//                                NavigationLink(destination: PrivacyPolicyView(), isActive: $navigateToPrivacyPolicy) {
//                                    ProfileMenuItem(icon: "doc.text", text: "Privacy & Policy") {
//                                        navigateToPrivacyPolicy = true
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 20)
//                        }
//                    }
//                    .background(Color(.systemBackground))
//                    
//                    if viewModel.authUser != nil {
//                        Button(action: signOut) {
//                            Text("Log Out")
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
//                                .frame(height: 55)
//                                .frame(maxWidth: .infinity)
//                                .background(Color.red)
//                                .cornerRadius(10)
//                                .shadow(color: .gray.opacity(0.2), radius: 2)
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 20)
//                        .background(Color(.systemBackground))
//                    }
//                } else {
//                    Color.clear
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    if authViewModel.isAuthenticated {
//                        Button(action: {
//                            selectedTab = "search"
//                            dismiss()
//                        }) {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    if authViewModel.isAuthenticated {
//                        NavigationLink(destination: NotificationsView(viewModel: viewModel), isActive: $navigateToNotifications) {
//                            ZStack {
//                                Image(systemName: "bell.fill")
//                                    .foregroundColor(viewModel.unreadCount > 0 ? .blue : .gray)
//                                    .font(.system(size: 20))
//                                if viewModel.unreadCount > 0 {
//                                    Text("\(viewModel.unreadCount)")
//                                        .font(.system(size: 12, weight: .bold))
//                                        .foregroundColor(.white)
//                                        .padding(4)
//                                        .background(Color.red)
//                                        .clipShape(Circle())
//                                        .offset(x: 10, y: -10)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .background(
//                NavigationLink(destination: UserProfileEditView()
//                    .environmentObject(viewModel)
//                    .environmentObject(cartManager)
//                    .environmentObject(authViewModel)
//                    .onDisappear {
//                        Task { await viewModel.loadCurrentUser(forceServer: true) }
//                    },
//                    isActive: $navigateToEditProfile) { EmptyView() }
//            )
//            .onAppear {
//                print("UserProfileView onAppear")
//                // CHANGE: Clear cache to avoid stale images
//                if let photoUrl = viewModel.user?.photoUrl {
//                    ProfileImageCache.shared.removeImage(forKey: photoUrl)
//                    print("Cleared image cache for: \(photoUrl)")
//                }
//                // CHANGE: Force load user data
//                Task {
//                    await viewModel.loadCurrentUser(forceServer: true)
//                }
//            }
//            .alert(isPresented: $showResetPasswordAlert) {
//                Alert(
//                    title: Text("Password Reset"),
//                    message: Text(resetPasswordMessage ?? ""),
//                    dismissButton: .default(Text("OK")) {
//                        signOut()
//                    }
//                )
//            }
//        }
//    }
//    
//    private func resetPassword() {
//        guard let email = viewModel.user?.email else {
//            resetPasswordMessage = "Email not available"
//            showResetPasswordAlert = true
//            return
//        }
//        Task {
//            do {
//                try await AuthenticationManager.shared.resetPassword(email: email)
//                resetPasswordMessage = "Password reset link sent to \(email)"
//                showResetPasswordAlert = true
//            } catch {
//                resetPasswordMessage = "Failed to send reset email: \(error)"
//                showResetPasswordAlert = true
//            }
//        }
//    }
//    
//    private func signOut() {
//        Task {
//            do {
//                try AuthenticationManager.shared.signOut()
//                authViewModel.checkAuthenticationStatus()
//                selectedTab = "search"
//                dismiss()
//            } catch {
//                print("Sign-out failed: \(error)")
//            }
//        }
//    }
//}
//
//struct GradientBackground: View {
//    var body: some View {
//        GeometryReader { geometry in
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.gray.opacity(0.2),
//                    Color.blue.opacity(0.1),
//                    Color.clear
//                ]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//    }
//}
//
//struct ProfileMenuItem: View {
//    let icon: String
//    let text: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.blue)
//                    .font(.system(size: 20, weight: .medium))
//                Text(text)
//                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                    .foregroundColor(.primary)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)
//        }
//    }
//}
//
//struct NotificationsView: View {
//    @ObservedObject var viewModel: UserProfileViewModel
//
//    var body: some View {
//        List {
//            ForEach(viewModel.notifications) { notification in
//                VStack(alignment: .leading) {
//                    Text(notification.title)
//                        .font(.headline)
//                        .foregroundColor(notification.isRead ? .gray : .black)
//                    Text(notification.body)
//                        .font(.subheadline)
//                    Text(notification.timestamp, style: .date)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                .onTapGesture {
//                    Task { await viewModel.markNotificationAsRead(id: notification.id, rentalId: notification.rentalId) }
//                }
//            }
//        }
//        .navigationTitle("Notifications")
//    }
//}
//
//#Preview {
//    UserProfileView(selectedTab: .constant(nil))
//        .environmentObject(CartManager())
//        .environmentObject(AuthenticationViewModel())
//        .environmentObject(UserProfileViewModel())
//}
