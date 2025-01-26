//
//  SignUpView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/12/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Email TextField
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocapitalization(.none)

            // Password TextField with toggle
            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
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

            // Confirm Password TextField with toggle
            HStack {
                if showConfirmPassword {
                    TextField("Confirm Password", text: $confirmPassword)
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)

            // Error Message Display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Sign Up Button
            Button(action: handleSignUp) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.blue)
        })
        .alert("Registration Successful!", isPresented: $showSuccessAlert) {
            Button("OK") {
                authViewModel.isAuthenticated = true // Trigger navigation to `EquipmentListingView`
            }
        } message: {
            Text("You have successfully signed up and are now logged in.")
        }
    }

    private func handleSignUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        Task {
            do {
                try await authViewModel.signUpAndLogin(email: email, password: password)
                errorMessage = nil
                showSuccessAlert = true // Display the alert
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}


//
//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var showPassword: Bool = false
//    @State private var showConfirmPassword: Bool = false
//    @State private var errorMessage: String?
//    @State private var showSuccessAlert: Bool = false
//    @EnvironmentObject var authViewModel: AuthenticationViewModel
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack {
//            // Email TextField
//            TextField("Email", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//                .autocapitalization(.none)
//
//            // Password TextField with toggle
//            HStack {
//                if showPassword {
//                    TextField("Password", text: $password)
//                } else {
//                    SecureField("Password", text: $password)
//                }
//                Button(action: { showPassword.toggle() }) {
//                    Image(systemName: showPassword ? "eye.slash" : "eye")
//                        .foregroundColor(.gray)
//                }
//                .padding(.trailing, 10)
//            }
//            .padding()
//            .background(Color.gray.opacity(0.4))
//            .cornerRadius(10)
//
//            // Confirm Password TextField with toggle
//            HStack {
//                if showConfirmPassword {
//                    TextField("Confirm Password", text: $confirmPassword)
//                } else {
//                    SecureField("Confirm Password", text: $confirmPassword)
//                }
//                Button(action: { showConfirmPassword.toggle() }) {
//                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
//                        .foregroundColor(.gray)
//                }
//                .padding(.trailing, 10)
//            }
//            .padding()
//            .background(Color.gray.opacity(0.4))
//            .cornerRadius(10)
//
//            // Error Message Display
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            // Sign Up Button
//            Button(action: handleSignUp) {
//                Text("Sign Up")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Sign Up")
//        .alert("Registration Successful!", isPresented: $showSuccessAlert) {
//            Button("OK") {
//                authViewModel.isAuthenticated = true // Trigger navigation to `EquipmentListingView`
//            }
//        } message: {
//            Text("You have successfully signed up and are now logged in.")
//        }
//    }
//
//    private func handleSignUp() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match."
//            return
//        }
//
//        Task {
//            do {
//                try await authViewModel.signUpAndLogin(email: email, password: password)
//                errorMessage = nil
//                showSuccessAlert = true // Display the alert
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//        }
//    }
//}



//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @State private var showSuccessAlert: Bool = false
//    @EnvironmentObject var authViewModel: AuthenticationViewModel  // ✅ Use shared auth state
//
//    var body: some View {
//        VStack {
//            TextField("Email", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//                .autocapitalization(.none)
//
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//            SecureField("Confirm Password", text: $confirmPassword)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            Button(action: signUp) {
//                Text("Sign Up")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Sign Up")
//        .alert("Registration Successful!", isPresented: $showSuccessAlert) {
//            Button("OK") {
//                authViewModel.isAuthenticated = true  // ✅ Update authentication state
//            }
//        } message: {
//            Text("You have successfully signed up and are now logged in.")
//        }
//    }
//
//    private func signUp() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match"
//            return
//        }
//
//        Task {
//            do {
//                try await authViewModel.signUpAndLogin(email: email, password: password)
//                errorMessage = nil
//                showSuccessAlert = true
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//        }
//    }
//}
//

//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @State private var showSuccessAlert: Bool = false
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack {
//            TextField("Email", text: $email)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//                .autocapitalization(.none)
//
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//            SecureField("Confirm Password", text: $confirmPassword)
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            Button(action: signUp) {
//                Text("Sign Up")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Sign Up")
//        .alert("Registration Successful!", isPresented: $showSuccessAlert) {
//            Button("OK") {
//                // Navigate to EquipmentListingView after dismissing the alert
//                DispatchQueue.main.async {
//                    presentationMode.wrappedValue.dismiss()
//                    RootView().checkAuthenticationStatus()
//                }
//            }
//        } message: {
//            Text("You have successfully signed up and are now logged in.")
//        }
//    }
//
//    private func signUp() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match"
//            return
//        }
//
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else if let user = authResult?.user {
//                saveUserToFirestore(user)
//                errorMessage = nil
//                showSuccessAlert = true // Show alert upon successful sign-up
//            }
//        }
//    }
//
//    private func saveUserToFirestore(_ user: User) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.uid)
//
//        let userData: [String: Any] = [
//            "email": user.email ?? "",
//            "created_at": Timestamp(date: Date())
//        ]
//
//        userRef.setData(userData) { error in
//            if let error = error {
//                print("Error saving user to Firestore: \(error.localizedDescription)")
//            } else {
//                print("User successfully added to Firestore")
//            }
//        }
//    }
//}


//
//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @State private var isSignUpSuccessful: Bool = false
//    @State private var showPassword: Bool = false // Toggle for password visibility
//    @State private var showConfirmPassword: Bool = false // Toggle for confirm password visibility
//    @Environment(\.presentationMode) var presentationMode // For navigating back
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Email", text: $email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//
//                // Password Field with Toggle
//                HStack {
//                    if showPassword {
//                        TextField("Password", text: $password)
//                    } else {
//                        SecureField("Password", text: $password)
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
//                // Confirm Password Field with Toggle
//                HStack {
//                    if showConfirmPassword {
//                        TextField("Confirm Password", text: $confirmPassword)
//                    } else {
//                        SecureField("Confirm Password", text: $confirmPassword)
//                    }
//                    Button(action: { showConfirmPassword.toggle() }) {
//                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.trailing, 10)
//                }
//                .padding()
//                .background(Color.gray.opacity(0.4))
//                .cornerRadius(10)
//
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//
//                Button(action: signUp) {
//                    Text("Sign Up")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.top, 10)
//
//                Spacer()
//            }
//            .padding()
//            .navigationBarTitle("Sign Up", displayMode: .inline)
//            .navigationBarItems(leading: Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.blue)
//            })
//            
//            .alert("Success", isPresented: $isSignUpSuccessful) {
//                Button("OK") {
//                    presentationMode.wrappedValue.dismiss() // Navigate back to login
//                }
//            } message: {
//                Text("Your account has been created successfully! You have been signed out.")
//            }
//
////            .alert("Success", isPresented: $isSignUpSuccessful) {
////                Button("OK") {
////                    presentationMode.wrappedValue.dismiss() // Navigate back
////                }
////            } message: {
////                Text("Your account has been created successfully!")
////            }
//        }
//    }
//    //
////    updated signUp function that retains the check to verify if the user's email already exists in Firebase before proceeding with sign-up, while also ensuring the user is signed out after account creation.
//    
//    
//    private func signUp() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match"
//            return
//        }
//
//        // Check if email already exists before creating the user
//        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
//            if let error = error {
//                errorMessage = "Error checking email: \(error.localizedDescription)"
//                return
//            }
//
//            if let signInMethods = signInMethods, !signInMethods.isEmpty {
//                errorMessage = "This email is already in use. Please use a different one."
//            } else {
//                // Proceed with user creation
//                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//                    if let error = error {
//                        errorMessage = error.localizedDescription
//                    } else if let user = authResult?.user {
//                        // Success: Save user details to Firestore
//                        saveUserToFirestore(user)
//                        errorMessage = nil
//                        isSignUpSuccessful = true // Show success message
//                    }
////                    else {
////                        errorMessage = nil
////                        isSignUpSuccessful = true // Show success message
////                    }
//                }
//            }
//        }
//    }
//    
//    
////    private func signUp() {
////        guard password == confirmPassword else {
////            errorMessage = "Passwords do not match"
////            return
////        }
////
////        // Check if email already exists before creating the user
////        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
////            if let error = error {
////                errorMessage = "Error checking email: \(error.localizedDescription)"
////                return
////            }
////
////            if let signInMethods = signInMethods, !signInMethods.isEmpty {
////                errorMessage = "This email is already in use. Please use a different one."
////            } else {
////                // Proceed with user creation
////                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
////                    if let error = error {
////                        errorMessage = error.localizedDescription
////                    } else if let user = authResult?.user {
////                        // Success: Save user details to Firestore
////                        saveUserToFirestore(user)
////                    }
////                }
////            }
////        }
////    }
//    
////
////    private func signUp() {
////        guard password == confirmPassword else {
////            errorMessage = "Passwords do not match"
////            return
////        }
////
////        // Check if email already exists before creating the user
////        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
////            if let error = error {
////                errorMessage = "Error checking email: \(error.localizedDescription)"
////                return
////            }
////
////            if let signInMethods = signInMethods, !signInMethods.isEmpty {
////                errorMessage = "This email is already in use. Please use a different one."
////            } else {
////                // Proceed with user creation
////                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
////                    if let error = error {
////                        errorMessage = error.localizedDescription
////                    } else {
////                        errorMessage = nil
////                        isSignUpSuccessful = true // Show success message
////                        
////                        // Delay before signing out to allow Firebase to register the user
////                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////                            do {
////                                try Auth.auth().signOut()
////                            } catch let signOutError {
////                                print("Error signing out: \(signOutError.localizedDescription)")
////                            }
////                        }
////                    }
////                }
////            }
////        }
////    }
//
//    
////    private func signUp() {
////        guard password == confirmPassword else {
////            errorMessage = "Passwords do not match"
////            return
////        }
////
////        // Check if email already exists before creating the user
////        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
////            if let error = error {
////                errorMessage = "Error checking email: \(error.localizedDescription)"
////                return
////            }
////
////            if let signInMethods = signInMethods, !signInMethods.isEmpty {
////                errorMessage = "This email is already in use. Please use a different one."
////            } else {
////                // Proceed with user creation
////                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
////                    if let error = error {
////                        errorMessage = error.localizedDescription
////                    } else {
////                        errorMessage = nil
////                        isSignUpSuccessful = true // Show success message
////                        
////                        // Sign out the user after successful sign-up
////                        do {
////                            try Auth.auth().signOut()
////                        } catch let signOutError {
////                            print("Error signing out: \(signOutError.localizedDescription)")
////                        }
////                    }
////                }
////            }
////        }
////    }
//
//
////    private func signUp() {
////        guard password == confirmPassword else {
////            errorMessage = "Passwords do not match"
////            return
////        }
////
////        // Check if email already exists before creating the user
////        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
////            if let error = error {
////                errorMessage = "Error checking email: \(error.localizedDescription)"
////                return
////            }
////
////            if let signInMethods = signInMethods, !signInMethods.isEmpty {
////                errorMessage = "This email is already in use. Please use a different one."
////            } else {
////                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
////                    if let error = error {
////                        errorMessage = error.localizedDescription
////                    } else {
////                        errorMessage = nil
////                        isSignUpSuccessful = true // Show success message
////                    }
////                }
////            }
////        }
////    }
//    
//    private func saveUserToFirestore(_ user: User) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(user.uid) // Use user ID as document ID
//        
//        let userData: [String: Any] = [
//            "doc_id": user.uid,         // Store user ID in 'doc_id' field
//            "email": user.email ?? "",
//            "isAnonymous": user.isAnonymous,
//            "created_at": Timestamp(date: Date()), // Store the creation timestamp
//            "lastname": "",               // Default empty string
//            "firstname": "",              // Default empty string
//            "is_admin": false,            // Default false
//            "img_url": ""                 // Default empty string for profile image
//        ]
//        
//        userRef.setData(userData) { error in
//            if let error = error {
//                print("Error saving user to Firestore: \(error.localizedDescription)")
//            } else {
//                print("User successfully added to Firestore with default values")
//            }
//        }
//    }
//
//}
//
//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}




//import SwiftUI
//import FirebaseAuth
//
//struct SignUpView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var errorMessage: String?
//    @Environment(\.presentationMode) var presentationMode // Add this line
//
//    var body: some View {
//        NavigationView { // Wrap in NavigationView
//            VStack {
//                TextField("Email", text: $email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//
//                SecureField("Password", text: $password)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//
//                SecureField("Confirm Password", text: $confirmPassword)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//
//                if let errorMessage = errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//
//                Button(action: signUp) {
//                    Text("Sign Up")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                Spacer()
//                .padding(.top, 20)
//            }
//                    
//            .padding()
//            .navigationBarTitle("Sign Up", displayMode: .inline) // Add title
//            .navigationBarItems(leading: Button(action: {
//                presentationMode.wrappedValue.dismiss() // Add this line
//            }) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.blue)
//            })
//        }
//    }
//
//    private func signUp() {
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match"
//            return
//        }
//
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else {
//                // Handle successful sign up
//                errorMessage = nil
//            }
//        }
//    }
//}
//
//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
