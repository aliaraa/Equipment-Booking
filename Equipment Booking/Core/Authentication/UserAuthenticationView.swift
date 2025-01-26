//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices // for Apple Sign-In

struct UserAuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @State private var showPassword: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToSignUp: Bool = false // For navigation to SignUpView

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Welcome Message
                Text("Welcome")
                    .font(.largeTitle)
                    .padding(.vertical, 20)

                // Sign-in Email Section
                VStack {
                    // Email Field
                    TextField("Email...", text: $viewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                        .autocapitalization(.none)

                    // Password Field
                    HStack {
                        if showPassword {
                            TextField("Password...", text: $viewModel.password)
                        } else {
                            SecureField("Password...", text: $viewModel.password)
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)

                    // Error Message with Inline Buttons
                    if let errorMessage = errorMessage {
                        VStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.bottom, 5)
                            HStack {
                                Button("New User? Sign Up") {
                                    navigateToSignUp = true // Trigger navigation
                                }
                                .foregroundColor(.blue)

                                Spacer()

                                Button("Forgot Password?") {
                                    showForgotPassword = true // Present ForgotPasswordView
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }

                // Sign In Button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            errorMessage = nil // Clear any previous errors
                            showSignInView = false // Dismiss UserAuthenticationView
                        } catch let error as NSError {
                            print("Sign-in error: \(error.domain) - \(error.localizedDescription)")
                            if error.domain == "EmailNotRegistered" {
                                errorMessage = "Email not registered. Please sign up or try again."
                            } else if error.domain == "InvalidPassword" {
                                errorMessage = "Incorrect password. Please try again."
                            } else {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                // Section Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)

                    Text("or")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 8)

                // Social Sign-In Buttons
                VStack(spacing: 10) {
                    // Sign in with Google
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await viewModel.signInGoogle()
                                showSignInView = false // Dismiss authentication view
                            } catch {
                                print("Google Sign-In Error: \(error)")
                            }
                        }
                    }
                    .frame(height: 55)

                    // Sign in with Apple
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .frame(height: 55)
                }

                Spacer()

                // Navigation to SignUpView
                NavigationLink(destination: SignUpView().environmentObject(viewModel), isActive: $navigateToSignUp) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $viewModel.email, onDismiss: { showForgotPassword = false })
            }
        }
    }
}

// Struct for apple sign in
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}


//import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift
//import AuthenticationServices // for Apple Sign-In
//
//struct UserAuthenticationView: View {
//    @StateObject private var viewModel = AuthenticationViewModel()
//    @Binding var showSignInView: Bool
//    @State private var showPassword: Bool = false
//    @State private var showForgotPassword: Bool = false
//    @State private var errorMessage: String? = nil
//    @State private var showInlineSignUp: Bool = false
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                // Welcome Message
//                Text("Welcome")
//                    .font(.largeTitle)
//                    .padding(.vertical, 20)
//
//                // Sign-in Email Section
//                VStack {
//                    // Email Field
//                    TextField("Email...", text: $viewModel.email)
//                        .padding()
//                        .background(Color.gray.opacity(0.4))
//                        .cornerRadius(10)
//                        .autocapitalization(.none)
//
//                    // Password Field
//                    HStack {
//                        if showPassword {
//                            TextField("Password...", text: $viewModel.password)
//                        } else {
//                            SecureField("Password...", text: $viewModel.password)
//                        }
//                        Button(action: { showPassword.toggle() }) {
//                            Image(systemName: showPassword ? "eye.slash" : "eye")
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.trailing, 10)
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//
//                    // Error Message with Inline Buttons
//                    if let errorMessage = errorMessage {
//                        VStack {
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                                .padding(.bottom, 5)
//                            if showInlineSignUp {
//                                HStack {
//                                    Button("New User? Sign Up") {
//                                        showSignInView = false // Dismiss the current view
//                                    }
//                                    .foregroundColor(.blue)
//
//                                    Spacer()
//
//                                    Button("Forgot Password?") {
//                                        showForgotPassword = true
//                                    }
//                                    .foregroundColor(.blue)
//                                }
//                            }
//                        }
//                    }
//                }
//
//                // Sign In Button
//                Button {
//                    Task {
//                        do {
//                            try await viewModel.signIn()
//                            errorMessage = nil // Clear any previous errors
//                            showSignInView = false // Dismiss UserAuthenticationView
//                        } catch let error as NSError {
//                            print("Sign-in error: \(error.domain) - \(error.localizedDescription)")
//                            if error.domain == "EmailNotRegistered" {
//                                errorMessage = "Email not registered. Please sign up or try again."
//                                showInlineSignUp = true
//                            } else if error.domain == "InvalidPassword" {
//                                errorMessage = "Incorrect password. Please try again."
//                                showInlineSignUp = false
//                            } else {
//                                errorMessage = error.localizedDescription
//                                showInlineSignUp = false
//                            }
//                        }
//                    }
//                } label: {
//                    Text("Sign In")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//
//                // Section Divider
//                HStack {
//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal, 8)
//
//                    Text("or")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal, 8)
//
//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal, 8)
//                }
//                .padding(.vertical, 8)
//
//                // Social Sign-In Buttons
//                VStack(spacing: 10) {
//                    // Sign in with Google
//                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
//                        Task {
//                            do {
//                                try await viewModel.signInGoogle()
//                                showSignInView = false // Dismiss authentication view
//                            } catch {
//                                print("Google Sign-In Error: \(error)")
//                            }
//                        }
//                    }
//                    .frame(height: 55)
//
//                    // Sign in with Apple
//                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                        .frame(height: 55)
//                }
//
//                // Sign Up Button
//                if !showInlineSignUp {
//                    NavigationLink(destination: SignUpView().environmentObject(viewModel)) {
//                        Text("Don't have an account? Sign Up")
//                            .foregroundColor(.blue)
//                            .padding(.top, 10)
//                    }
//                }
//
//                Spacer()
//
//                // Footer with Home Button and Profile Image
//                HStack {
//                    // Home Button
//                    NavigationLink(destination: EquipmentListingView()) {
//                        Image(systemName: "house.fill")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.gray)
//                    }
//
//                    Spacer()
//
//                    // Profile Image Button
//                    NavigationLink(destination: UserProfileView()) {
//                        Image(systemName: "person.crop.circle")
//                            .resizable()
//                            .frame(width: 40, height: 40)
//                            .foregroundColor(.gray)
//                    }
//                }
//                .frame(height: 60)
//                .padding(.horizontal)
//            }
//            .padding()
//            .navigationTitle("Sign In")
//            .navigationBarTitleDisplayMode(.inline)
//            .sheet(isPresented: $showForgotPassword) {
//                ForgotPasswordView(email: $viewModel.email)
//            }
//        }
//    }
//}
//
//
//// Struct for apple sign in
//struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
//    let type: ASAuthorizationAppleIDButton.ButtonType
//    let style: ASAuthorizationAppleIDButton.Style
//
//    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
//        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
//    }
//
//    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
//        // No need to update the button dynamically
//    }
//}



#Preview {
    UserAuthenticationView(showSignInView: .constant(true))
}



//import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift
//import AuthenticationServices // for apple sign in
//
//// apple sign in button using UIKit
//struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
//    
//    let type: ASAuthorizationAppleIDButton.ButtonType
//    let style: ASAuthorizationAppleIDButton.Style
//    
//    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
//    }
//    
//    
//    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
//        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
//        
//    }
//    
//    
//}
//
//struct UserAuthenticationView: View {
//    @StateObject private var viewModel = AuthenticationViewModel()
//    @Binding var showSignInView: Bool
//    @State private var showPassword: Bool = false
//    @State private var showSignUp: Bool = false
//    @State private var showForgotPassword: Bool = false
//    @State private var errorMessage: String? = nil
//    @State private var showInlineSignUp: Bool = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Welcome Message
//            Text("Welcome")
//                .font(.largeTitle)
//                .padding(.vertical, 20)
//            
//            // Sign-in Email Section
//            VStack {
//                // Email Field
//                TextField("Email...", text: $viewModel.email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                    .autocapitalization(.none)
//                
//                // Password Field
//                HStack {
//                    if showPassword {
//                        TextField("Password...", text: $viewModel.password)
//                    } else {
//                        SecureField("Password...", text: $viewModel.password)
//                    }
//                    Button(action: { showPassword.toggle() }) {
//                        Image(systemName: showPassword ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.trailing, 10)
//                }
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//                
//                // Error Message with Inline Buttons
//                if let errorMessage = errorMessage {
//                    VStack {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding(.bottom, 5)
//                        if showInlineSignUp {
//                            HStack {
//                                Button("New User? Sign Up") {
//                                    showSignUp = true
//                                }
//                                .foregroundColor(.blue)
//                                
//                                Spacer()
//                                
//                                Button("Forgot Password?") {
//                                    showForgotPassword = true
//                                }
//                                .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                }
//            }
//            
//            // Sign In Button
//            Button {
//                Task {
//                    do {
//                        try await viewModel.signIn()
//                        showSignInView = false // Close authentication screen
//                    } catch let error as NSError {
//                        if error.domain == "EmailNotRegistered" {
//                            errorMessage = "Email not registered. Please sign up or try again."
//                        } else if error.domain == "InvalidPassword" {
//                            errorMessage = "Incorrect password. Please try again."
//                        } else {
//                            errorMessage = error.localizedDescription
//                        }
//                    }
//                }
//            } label: {
//                Text("Sign In")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//
////            Button {
////                Task {
////                    do {
////                        try await viewModel.signIn()
////                        showSignInView = false // Close authentication screen
////                        // Navigate to EquipmentListingView after successful sign-in
////                        DispatchQueue.main.async {
////                            NavigationStack {
////                                EquipmentListingView()
////                            }
////                        }
////                    } catch {
////                        errorMessage = "Sign-in failed. Please try again."
////                    }
////                }
////            } label: {
////                Text("Sign In")
////                    .font(.headline)
////                    .foregroundColor(.white)
////                    .frame(height: 55)
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(10)
////            }
//
//            
////            Button {
////                Task {
////                    do {
////                        // Attempt sign-in
////                        try await viewModel.signIn()
////                        
////                        // On success, clear errors and navigate
////                        errorMessage = nil
////                        showInlineSignUp = false
////                        showSignInView = false // Dismiss authentication view
////                    } catch let error as NSError {
////                        print("Sign-in error: \(error.domain) - \(error.localizedDescription)") // Debugging log
////                        
////                        // Handle specific errors
////                        if error.domain == "EmailNotRegistered" {
////                            errorMessage = "Email not registered. Please sign up or try again."
////                            showInlineSignUp = true
////                        } else if error.domain == "InvalidPassword" {
////                            errorMessage = "Incorrect password. Please try again or reset it."
////                            showInlineSignUp = false
////                        } else if error.domain == "InvalidCredential" {
////                            errorMessage = "Invalid credentials. Please check your email and password."
////                            showInlineSignUp = false
////                        } else {
////                            errorMessage = error.localizedDescription
////                            showInlineSignUp = false
////                        }
////                    }
////                }
////            } label: {
////                Text("Sign In")
////                    .font(.headline)
////                    .foregroundColor(.white)
////                    .frame(height: 55)
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(10)
////            }
//
//            
////            Button {
////                Task {
////                    do {
////                        // Attempt sign-in
////                        try await viewModel.signIn()
////
////                        // On success, clear errors and navigate
////                        errorMessage = nil
////                        showInlineSignUp = false
////                        showSignInView = false // Dismiss authentication view
////                    } catch let error as NSError {
////                        print("Sign-in error: \(error.domain) - \(error.localizedDescription)") // Debugging log
////
////                        // Handle specific errors
////                        if error.domain == "EmailNotRegistered" {
////                            errorMessage = "Email not registered. Please sign up or try again."
////                            showInlineSignUp = true
////                        } else if error.domain == "InvalidPassword" {
////                            errorMessage = "Incorrect password. Please try again or reset it."
////                            showInlineSignUp = false
////                        } else if error.domain == "InvalidCredential" {
////                            errorMessage = "The entered email or password is invalid. Please check your credentials."
////                            showInlineSignUp = false
////                        } else {
////                            errorMessage = error.localizedDescription // Show detailed error for debugging
////                            showInlineSignUp = false
////                        }
////                    }
////                }
////            } label: {
////                Text("Sign In")
////                    .font(.headline)
////                    .foregroundColor(.white)
////                    .frame(height: 55)
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(10)
////            }
//
//            
////            Button {
////                Task {
////                    do {
////                        // Attempt sign-in
////                        try await viewModel.signIn()
////
////                        // If successful, navigate to EquipmentListingView
////                        showSignInView = false
////                    } catch let error as NSError {
////                        print("Sign-in error in UI: \(error.domain) - \(error.localizedDescription)")
////
////                        if error.domain == "EmailNotRegistered" {
////                            errorMessage = "Email not registered. Please sign up or try again."
////                            showInlineSignUp = true
////                        } else if error.domain == "InvalidPassword" {
////                            errorMessage = "Incorrect password. Please try again or reset it."
////                            showInlineSignUp = false
////                        } else if error.domain == "InvalidCredential" {
////                            errorMessage = "The entered email or password is invalid. Please check your credentials."
////                            showInlineSignUp = false
////                        } else {
////                            errorMessage = error.localizedDescription
////                            showInlineSignUp = false
////                        }
////                    }
////                }
////            } label: {
////                Text("Sign In")
////                    .font(.headline)
////                    .foregroundColor(.white)
////                    .frame(height: 55)
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(10)
////            }
////
//            
//            // Section Divider
//            HStack {
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//                
//                Text("or")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//                
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//            }
//            .padding(.vertical, 8)
//            
//            // Social Sign-In Buttons
//            VStack(spacing: 10) {
//                // Sign in with Google
//                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
//                    Task {
//                        do {
//                            try await viewModel.signInGoogle()
//                            showSignInView = false // Dismiss authentication view
//                        } catch {
//                            print("Google Sign-In Error: \(error)")
//                        }
//                    }
//                }
//                .frame(height: 55)
//                
//                // Sign in with Apple
//                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                    .frame(height: 55)
//            }
//            
//            // Sign Up Button (below Sign in with Apple)
//            if !showInlineSignUp {
//                Button("Don't have an account? Sign Up") {
//                    showSignUp = true
//                }
//                .foregroundColor(.blue)
//                .padding(.top, 10)
//            }
//            
//            Spacer()
//            
//            // Footer with Home Button and Profile Image
//            HStack {
//                // Home Button
//                NavigationLink(destination: EquipmentListingView()) {
//                    Image(systemName: "house.fill")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.gray)
//                }
//
//                Spacer()
//
//                // Profile Image Button
//                NavigationLink(destination: UserProfileView()) {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.gray)
//                }
//            }
//            .frame(height: 60)
//            .padding(.horizontal)
//        }
//        .padding()
//        .onAppear {
//            // Reset state on appearance
//            errorMessage = nil
//            showInlineSignUp = false
//        }
//        .sheet(isPresented: $showSignUp) {
//            SignUpView()
//        }
//        .sheet(isPresented: $showForgotPassword) {
//            ForgotPasswordView(email: $viewModel.email)
//        }
//    }
//}

//struct UserAuthenticationView: View {
//    @StateObject private var viewModel = AuthenticationViewModel()
//    @Binding var showSignInView: Bool
//    @State private var showPassword: Bool = false
//    @State private var showSignUp: Bool = false
//    @State private var showForgotPassword: Bool = false
//    @State private var errorMessage: String? = nil
//    @State private var showInlineSignUp: Bool = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Welcome Message
//            Text("Welcome")
//                .font(.largeTitle)
//                .padding(.vertical, 20)
//
//            // Sign-in Email Section
//            VStack {
//                // Email Field
//                TextField("Email...", text: $viewModel.email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//
//                // Password Field
//                HStack {
//                    if showPassword {
//                        TextField("Password...", text: $viewModel.password)
//                    } else {
//                        SecureField("Password...", text: $viewModel.password)
//                    }
//                    Button(action: { showPassword.toggle() }) {
//                        Image(systemName: showPassword ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.trailing, 10)
//                }
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//                // Error Message with Inline Buttons
//                if let errorMessage = errorMessage {
//                    VStack {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding(.bottom, 5)
//                        if showInlineSignUp {
//                            HStack {
//                                Button("Sign Up") {
//                                    showSignUp = true
//                                }
//                                .foregroundColor(.blue)
//
//                                Button("Forgot Password?") {
//                                    showForgotPassword = true
//                                }
//                                .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                }
//            }
//
//            // Sign In Button
//            //Include logic to handle the navigation when a user is already signed in:
//
//            Button {
//                Task {
//                    do {
//                        // Attempt sign-in
//                        try await viewModel.signIn()
//
//                        // If successful, navigate to EquipmentListingView
//                        showSignInView = false
//                    } catch let error as NSError {
//                        if error.domain == "EmailNotRegistered" {
//                            errorMessage = "Email not registered. Please sign up or try again."
//                            showInlineSignUp = true
//                        } else if error.domain == "InvalidPassword" {
//                            errorMessage = "Incorrect password. Please try again or reset it."
//                            showInlineSignUp = false
//                        } else {
//                            errorMessage = error.localizedDescription
//                            showInlineSignUp = false
//                        }
//                    }
//                }
//            } label: {
//                Text("Sign In")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//
////            Button {
////                Task {
////                    do {
////                        // Attempt sign-in
////                        try await viewModel.signIn()
////                        
////                        // On success, clear errors and navigate
////                        errorMessage = nil
////                        showInlineSignUp = false
////                        showSignInView = false // Dismiss authentication view
////                    } catch {
////                        // Handle Errors
////                        if let error = error as NSError? {
////                            if error.domain == "EmailNotRegistered" {
////                                errorMessage = "Email not registered. Please sign up or try again."
////                                showInlineSignUp = true
////                            } else if error.domain == "InvalidPassword" {
////                                errorMessage = "Incorrect password. Please try again or reset it."
////                                showInlineSignUp = false
////                            } else {
////                                errorMessage = "An unknown error occurred."
////                                showInlineSignUp = false
////                            }
////                        }
////                    }
////                }
////            } label: {
////                Text("Sign In")
////                    .font(.headline)
////                    .foregroundColor(.white)
////                    .frame(height: 55)
////                    .frame(maxWidth: .infinity)
////                    .background(Color.blue)
////                    .cornerRadius(10)
////            }
//            
//            // Section Divider
//            HStack {
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//                
//                Text("or")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//                
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 8)
//            }
//            .padding(.vertical, 8)
//            
//            // Social Sign-In Buttons
//            VStack(spacing: 10) {
//                // Sign in with Google
//                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
//                    Task {
//                        do {
//                            try await viewModel.signInGoogle()
//                            showSignInView = false // Dismiss authentication view
//                        } catch {
//                            print("Google Sign-In Error: \(error)")
//                        }
//                    }
//                }
//                .frame(height: 55)
//                
//                // Sign in with Apple
//                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                    .frame(height: 55)
//            }
//            
//            
//            Spacer()
//            
//            // Footer with Home Button and Profile Image
//            HStack {
//                // Home Button
//                NavigationLink(destination: EquipmentListingView()) {
//                    Image(systemName: "house.fill")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.gray)
//                }
//
//                Spacer()
//
//                // Profile Image Button
//                NavigationLink(destination: UserProfileView()) {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.gray)
//                }
//            }
//            .frame(height: 60)
//            .padding(.horizontal)
//           
//            
//        }
//        .padding()
//        .onAppear {
//            // Reset state on appearance
//            errorMessage = nil
//            showInlineSignUp = false
//        }
//        .sheet(isPresented: $showSignUp) {
//            SignUpView()
//        }
//        .sheet(isPresented: $showForgotPassword) {
//            ForgotPasswordView(email: $viewModel.email)
//        }
//    }
//}








