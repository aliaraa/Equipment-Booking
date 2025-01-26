//
//  UserProfileView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/18/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    @Published var authUser: AuthDataResultModel? = nil
        
    
    func loadCurrentUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.authUser = authDataResult
            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)

            // Handle missing first name and last name
            if user?.firstName == nil || user?.lastName == nil {
                if let googleProfile = Auth.auth().currentUser?.providerData.first(where: { $0.providerID == "google.com" }) {
                    // Try to get names and photo from Google profile
                    let firstName = googleProfile.displayName?.components(separatedBy: " ").first
                    let lastName = googleProfile.displayName?.components(separatedBy: " ").dropFirst().joined(separator: " ")
                    let photoUrl = googleProfile.photoURL?.absoluteString
                    
                    // Update user instance
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: photoUrl ?? authDataResult.photoUrl,
                        firstName: firstName ?? authDataResult.email,
                        lastName: lastName
                        
                    )
                } else {
                    // Default to email if name is missing
                    self.user = DBUser(
                        userId: authDataResult.uid,
                        email: authDataResult.email,
                        photoUrl: authDataResult.photoUrl,
                        firstName: authDataResult.email,
                        lastName: nil
                        
                    )
                }
            }
        } catch {
            print("Failed to load user: \(error.localizedDescription)")
            self.user = DBUser(
                userId: "unknown",
                email: "Unknown User",
                firstName: "Anonymous",
                lastName: "User"
            )
        }
    }
    
    func updateUserProfile(firstName: String, lastName: String, phone: String, address: String, companyName: String, profession: String) async throws {
            guard let userId = user?.userId else { return }

            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)

            let updatedData: [String: Any] = [
                "firstname": firstName,
                "lastname": lastName,
                "phone": phone,
                "address": address,
                "company_name": companyName,
                "profession": profession
            ]

            try await userRef.updateData(updatedData)
            print("User profile updated successfully.")
        }
    
}


//import SwiftUI
//
//@MainActor
//final class UserProfileViewModel: ObservableObject {
//    @Published private(set) var user: DBUser? = nil
//    @Published var authUser: AuthDataResultModel? = nil
//    
//
//    func loadCurrentUser() async {
//        do {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
//        } catch {
//            print("Failed to load user: \(error.localizedDescription)")
//            self.user = DBUser(
//                userId: "unknown",
//                photoUrl: nil,
//                isAdmin: false,
//                firstName: "Anonymous",
//                lastName: "User"
//            )
//        }
//    }
//    
//    
//}



struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignIn = false // State to trigger navigation

    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.user {
                    // User Profile Image
                    AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
                        image.resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.top)
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding(.top)
                    }

                    // Display user's name or email if name is missing
                    Text(user.firstName ?? user.email ?? "Anonymous User")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 4)

                    Divider()
                        .padding(.vertical)

                    // Menu Items
                    List {

                        Button("My Rentals") {
                            print("My Rentals tapped")
                        }

                        NavigationLink(destination: UserSettingsView(showSignInView: $navigateToSignIn)) {
                            Text("Settings")
                        }

                        Button("Contact us") {
                            print("Support tapped")
                        }
                        
                        Button("Privacy & Policy") {
                            print("Privacy & Policy tapped")
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
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
                            navigateToSignIn = true // Set state to navigate
                        } catch {
                            print("Error during sign-out: \(error)")
                        }
                    }
                }
                label: {
                    Text("Log out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("User Profile")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSignIn) {
                UserAuthenticationView(showSignInView: $navigateToSignIn) // Navigate to sign-in view
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserProfileView()
        }
    }
}


//
//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var navigateToSignIn = false // State to trigger navigation
//
//    var body: some View {
//        NavigationStack {
//            VStack {
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
//                    // User's Name
//                    Text("\(user.firstName ?? "Anonymous") \(user.lastName ?? "User")")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.top, 4)
//
//                    Divider()
//                        .padding(.vertical)
//
//                    // Menu Items
//                    List {
//                        Button("Messages") {
//                            print("Messages tapped")
//                        }
//
//                        Button("My Rentals") {
//                            print("My Rentals tapped")
//                        }
//
//                        Button("User Settings") {
//                            print("User Settings tapped")
//                        }
//
//                        Button("Support") {
//                            print("Support tapped")
//                        }
//
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
//            .navigationTitle("User Profile")
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
//
//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            UserProfileView()
//        }
//    }
//}



//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var showSignInView: Bool // handle navigation after logout
//
//    var body: some View {
//        VStack {
//            if let user = viewModel.user {
//                // User Profile Image
//                AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                    image.resizable()
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .padding(.top)
//                } placeholder: {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.gray)
//                        .padding(.top)
//                }
//
//                // User's Name
//                Text("\(user.firstName ?? "Anonymous") \(user.lastName ?? "User")")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top, 4)
//
//                Divider()
//                    .padding(.vertical)
//
//                // Menu Items
//                List {
//                    Button("Messages") {
//                        //print("Messages tapped")
//                    }
//
//                    Button("My Rentals") {
//                        //print("My Rentals tapped")
//                    }
//
//                    Button("User Settings") {
//                        //print("User Settings tapped")
//                    }
//
//                    Button("Support") {
//                        //print("Support tapped")
//                    }
//
//                    Spacer()
//
////                    Button("Log out") {
////                        print("Log out tapped")
////                    }
////                    .foregroundColor(.red)
//                    
//                    Button{
//                        Task {
//                            do {
//                                try AuthenticationManager.shared.signOut()
//                                showSignInView = true // Navigate back to sign-in view
//                            } catch {
//                                print("Error during sign-out: \(error)")
//                            }
//                        }
//                    }
//                    label: {
//                        Text("Log out")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .frame(height: 55)
//                            .frame(maxWidth: .infinity)
//                            .background(Color.orange)
//                            .cornerRadius(10)
//                    }
////
//                    
//                }
//                .listStyle(InsetGroupedListStyle())
//            } else {
//                ProgressView("Loading user data...")
//                    .task {
//                        await viewModel.loadCurrentUser()
//                    }
//            }
//        }
//        .navigationTitle("User Profile")
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//    }
//}
//
//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            UserProfileView(showSignInView: .constant(false))
//        }
//    }
//}


//@MainActor
//final class UserProfileViewModel: ObservableObject {
//    @Published private(set) var user: DBUser? = nil
//
//    func loadCurrentUser() async {
//        do {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
//        } catch {
//            print("Failed to load user: \(error.localizedDescription)")
//            self.user = DBUser(
//                userId: "unknown",
//                photoUrl: nil,
//                firstName: "Anonymous",
//                lastName: "User"
//            )
//        }
//    }
//}



//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack {
//            if let user = viewModel.user {
//                // User Profile Image
//                AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                    image.resizable()
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .padding(.top)
//                } placeholder: {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.gray)
//                        .padding(.top)
//                }
//
//                // User's Name
//                Text("\(user.firstName ?? "Anonymous") \(user.lastName ?? "User")")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top, 4)
//
//                Divider()
//                    .padding(.vertical)
//
//                // Menu Items
//                List {
//                    Button("Messages") {
//                        print("Messages tapped")
//                    }
//
//                    Button("My Rentals") {
//                        print("My Rentals tapped")
//                    }
//
//                    Button("User Settings") {
//                        print("User Settings tapped")
//                    }
//
//                    Button("Support") {
//                        print("Support tapped")
//                    }
//
//                    Spacer()
//
//                    Button("Log out") {
//                        print("Log out tapped")
//                    }
//                    .foregroundColor(.red)
//                }
//                .listStyle(InsetGroupedListStyle())
//            } else {
//                ProgressView("Loading user data...")
//                    .task {
//                        await viewModel.loadCurrentUser()
//                    }
//            }
//        }
//        .navigationTitle("User Profile")
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//    }
//}
//
//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            UserProfileView()
//        }
//    }
//}


//import SwiftUI
//
//@MainActor
//final class UserProfileViewModel: ObservableObject {
//    @Published private(set) var user: DBUser? = nil
//
//    func loadCurrentUser() async {
//        do {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
//        } catch {
//            print("Failed to load user: \(error.localizedDescription)")
//            self.user = DBUser(
//                userId: "unknown",
//                photoUrl: nil,
//                firstName: "Anonymous",
//                lastName: "User"
//            )
//        }
//    }
//
//}
//
//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        VStack {
//            if let user = viewModel.user {
//                // User Profile Image
//                AsyncImage(url: URL(string: user.photoUrl ?? "")) { image in
//                    image.resizable()
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                        .padding(.top)
//                } placeholder: {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.gray)
//                        .padding(.top)
//                }
//
//                // User's Name
//                Text("\(user.firstName ?? "Anonymous") \(user.lastName ?? "User")")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top, 4)
//
//                Divider()
//                    .padding(.vertical)
//
//                // Menu Items
//                List {
//                    Button("Messages") {
//                        print("Messages tapped")
//                    }
//
//                    Button("My Rentals") {
//                        print("My Rentals tapped")
//                    }
//
//                    Button("User Settings") {
//                        print("User Settings tapped")
//                    }
//
//                    Button("Support") {
//                        print("Support tapped")
//                    }
//
//                    Spacer()
//
//                    Button("Log out") {
//                        print("Log out tapped")
//                    }
//                    .foregroundColor(.red)
//                }
//                .listStyle(InsetGroupedListStyle())
//            } else {
//                ProgressView("Loading user data...")
//                    .task {
//                        await viewModel.loadCurrentUser()
//                    }
//            }
//        }
//        .navigationTitle("User Profile")
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                }
//            }
//        }
//    }
//}
//
//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            UserProfileView()
//        }
//    }
//}


//import SwiftUI
//
//@MainActor
//
//final class UserProfileViewModel: ObservableObject {
//    
//    @Published private(set) var user: DBUser? = nil
//    
//    func loadCurrentUser() async throws {
//        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//        self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
//        
//    }
//     
//
//}
//
//struct UserProfileView: View {
//    @StateObject private var viewModel = UserProfileViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        if let user = viewModel.user {
//            VStack {
//                
//                
//                AsyncImage(url: URL(string: user.photoUrl??, "")) { image in
//                    image.resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.gray)
//                        .padding(.top)
//                } placeholder: {
//                    ProgressView()
//                    //Image(systemName: user.profileImage)
//                }
//                .shadow(radius: 10)
//                
//                
//                // User's Name
//                Text("\(viewModel.userFirstName) \(viewModel.userLastName)")
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .padding(.top, 4)
//                
//                Divider()
//                    .padding(.vertical)
//                
//                // Menu Items
//                List {
//                    Button("Messages") {
//                        print("Messages tapped")
//                    }
//                    
//                    Button("My Rentals") {
//                        print("My Rentals tapped")
//                    }
//                    
//                    Button("User Settings") {
//                        print("User Settings tapped")
//                    }
//                    
//                    Button("Support") {
//                        print("Support tapped")
//                    }
//                    
//                    Spacer()
//                    
//                    Button("Log out") {
//                        print("Log out tapped")
//                    }
//                    .foregroundColor(.red)
//                }
//                .listStyle(InsetGroupedListStyle())
//            }
//            .task {
//                await viewModel.loadCurrentUser()
//                
//            }
//            
//            .navigationTitle("User Profile")
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
//        }
//
//    }
//}
//
//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            UserProfileView()
//        }
//    }
//}



