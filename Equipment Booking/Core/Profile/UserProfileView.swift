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
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignIn = false
    @State private var navigateToSettings = false // ✅ Separate state for settings

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

                    // Menu Items
                    VStack(spacing: 15) {
                        ProfileMenuItem(icon: "list.bullet.rectangle", text: "My Rentals") {
                            print("My Rentals tapped")
                        }

                        // ✅ Correct binding for navigation
                        // ✅ Correct NavigationLink usage
                        NavigationLink(destination: UserSettingsView(showSignInView: $navigateToSignIn)) {
                            ProfileMenuItem(icon: "gearshape", text: "Settings")
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove button style from the NavigationLink

//                        NavigationLink(destination: UserSettingsView(showSignInView: $navigateToSignIn), isActive: $navigateToSettings) {
//                            ProfileMenuItem(icon: "gearshape", text: "Settings")
//                        }
//                        .buttonStyle(PlainButtonStyle())

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
                            navigateToSignIn = true
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
//            // ✅ Navigation for Settings (fixed)
//            .navigationDestination(isPresented: $navigateToSettings) {
//                UserSettingsView(showSignInView: $navigateToSignIn)
            }

            
        // ✅ Navigation for Sign-in (Separate)
        .navigationDestination(isPresented: $navigateToSignIn) {
            UserAuthenticationView(showSignInView: $navigateToSignIn)
        }
    }
}



// Reusable Profile Menu Item
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





//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
////
//// UserProfileView
//
//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var navigateToSignIn = false // State for sign-in navigation
//    @State private var navigateToSettings = false // State for settings navigation
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                if let user = viewModel.user {
//                    // User Profile Image
//                    AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                        image.resizable()
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
//                            .padding(.top)
//                    } placeholder: {
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.yellow)
//                            .padding(.top)
//                    }
//
//                    // Display user's name or email if name is missing
//                    Text(user.firstName ?? user.email ?? "Anonymous User")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//
//                    Divider().padding(.vertical)
//
//                    // Menu Items
//                    VStack(spacing: 15) {
//                        ProfileMenuItem(icon: "list.bullet.rectangle", text: "My Rentals") {
//                            print("My Rentals tapped")
//                        }
//
//                        // Navigate to Settings View
//                        Button {
//                            navigateToSettings = true
//                        } label: {
//                            ProfileMenuItem(icon: "gearshape", text: "Settings")
//                        }
//
//                        ProfileMenuItem(icon: "phone.fill", text: "Contact Us") {
//                            print("Support tapped")
//                        }
//
//                        ProfileMenuItem(icon: "doc.text.fill", text: "Privacy & Policy") {
//                            print("Privacy & Policy tapped")
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                } else {
//                    ProgressView("Loading user data...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//                
//                Spacer()
//
//                // Logout Button
//                Button {
//                    Task {
//                        do {
//                            try AuthenticationManager.shared.signOut()
//                            navigateToSignIn = true
//                        } catch {
//                            print("Error during sign-out: \(error)")
//                        }
//                    }
//                } label: {
//                    Text("Log out")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                }
//                .padding(.horizontal, 20)
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
//            // ✅ Navigate to Settings
//            .navigationDestination(isPresented: $navigateToSettings) {
//                UserSettingsView(showSignInView: $navigateToSettings)
//            }
//
//            // ✅ Navigate to Sign-in View
//            .navigationDestination(isPresented: $navigateToSignIn) {
//                UserAuthenticationView(showSignInView: $navigateToSignIn)
//            }
//        }
//    }
//}
//
//// Reusable Profile Menu Item
//struct ProfileMenuItem: View {
//    let icon: String
//    let text: String
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
//                    .foregroundColor(.black)
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
//    UserProfileView()
//}


//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var navigateToSignIn = false // State to trigger navigation
//
//    var body: some View {
//        NavigationStack {
//            VStack (spacing: 20){
//                if let user = viewModel.user {
//                    // User Profile Image
//                    AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                        image.resizable()
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
//                            .padding(.top)
//                    } placeholder: {
//                        Image(systemName: "person.crop.circle.fill")
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.yellow)
//                            .padding(.top)
//                    }
//
//                    // Display user's name or email if name is missing
//                    Text(user.firstName ?? user.email ?? "Anonymous User")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//
//                    Divider()
//                        .padding(.vertical)
//
//                    // Menu Items with yellow theme
//                    VStack(spacing: 15) {
//                        ProfileMenuItem(icon: "list.bullet.rectangle", text: "My Rentals") {
//                            print("My Rentals tapped")
//                        }
//                        
//                        NavigationLink(destination: UserSettingsView(showSignInView: $navigateToSignIn)) {
//                            ProfileMenuItem(icon: "gearshape", text: "Settings")
//                        }
//                        
//                        ProfileMenuItem(icon: "phone.fill", text: "Contact Us") {
//                            print("Support tapped")
//                        }
//                        
//                        ProfileMenuItem(icon: "doc.text.fill", text: "Privacy & Policy") {
//                            print("Privacy & Policy tapped")
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                } else {
//                    ProgressView("Loading user data...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//                
//                Spacer()
//
//                // Logout Button
//                Button {
//                    Task {
//                        do {
//                            try AuthenticationManager.shared.signOut()
//                            navigateToSignIn = true // Set state to navigate
//                        } catch {
//                            print("Error during sign-out: \(error)")
//                        }
//                    }
//                }
//                label: {
//                    Text("Log out")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .cornerRadius(10)
//                        .shadow(radius: 5)
//                }
//                .padding(.horizontal, 20)
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
//            .navigationDestination(isPresented: $navigateToSignIn) {
//                UserAuthenticationView(showSignInView: $navigateToSignIn) // Navigate to sign-in view
//            }
//        }
//    }
//}





//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var navigateToSignIn = false // State to trigger navigation
//
//    var body: some View {
//        NavigationStack {
//            VStack (spacing: 20){
//                if let user = viewModel.user {
//                    // User Profile Image
//                    AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                        image.resizable()
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
//                            .padding(.top)
//                    } placeholder: {
//                        Image(systemName: "person.crop.circle")
//                            .resizable()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.gray)
//                            .padding(.top)
//                    }
//
//                    // Display user's name or email if name is missing
//                    Text(user.firstName ?? user.email ?? "Anonymous User")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.top, 4)
//
//                    Divider()
//                        .padding(.vertical)
//
//                    // Menu Items
//                    List {
//
//                        Button("My Rentals") {
//                            print("My Rentals tapped")
//                        }
//
//                        NavigationLink(destination: UserSettingsView(showSignInView: $navigateToSignIn)) {
//                            Text("Settings")
//                        }
//
//                        Button("Contact us") {
//                            print("Support tapped")
//                        }
//                        
//                        Button("Privacy & Policy") {
//                            print("Privacy & Policy tapped")
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                } else {
//                    ProgressView("Loading user data...")
//                        .task {
//                            await viewModel.loadCurrentUser()
//                        }
//                }
//                Spacer()
//                Button {
//                    Task {
//                        do {
//                            try AuthenticationManager.shared.signOut()
//                            navigateToSignIn = true // Set state to navigate
//                        } catch {
//                            print("Error during sign-out: \(error)")
//                        }
//                    }
//                }
//                label: {
//                    Text("Log out")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.orange)
//                        .cornerRadius(10)
//                }
//                .padding()
//            }
//            //.navigationTitle("User Profile")
//            .navigationBarBackButtonHidden(true)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.headline)
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            .navigationDestination(isPresented: $navigateToSignIn) {
//                UserAuthenticationView(showSignInView: $navigateToSignIn) // Navigate to sign-in view
//            }
//        }
//    }
//}






