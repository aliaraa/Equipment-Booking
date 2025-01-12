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
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
    }
    
    func toggleAdminStatus(){
        guard let user else {return}
        let currentValue = user.isAdmin ?? false
        
        
//        let currentValue = user.isAdmin ?? false
//        let updatedUser = DBUser(userId: user.userId, isAnonymous: user.isAnonymous, email: user.email, photoUrl: user.photoUrl, dateCreated: user.dateCreated, isAdmin: !currentValue)
        //let updatedUser = user.toggleAdminStatus()
        
        Task{
            try await UserManager.shared.updateUserAdminStatus(userId: user.userId, isAdmin:!currentValue)
            self.user = try await UserManager.shared.getUser(userID: user.userId)
        }
        
    }
    
}




struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        List {
            
            if let user = viewModel.user {
                Text("userID: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous{
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button{
                    viewModel.toggleAdminStatus()
                    
                } label: {
                    Text("User is Admin: \((user.isAdmin ?? false).description.capitalized)")
                }
            }
            
            
        }
        .task {
            try? await viewModel.loadCurrentUser()
            
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink{
                    UserSettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                
                
            }
        }
        Spacer()
        
        NavigationView {
            VStack{
                NavigationLink (destination: EquipmentListingView()) {
                    
                    Text("Go to Equipment Listing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    
                }
                
            }
            .navigationTitle("Equipment Listing")
        }
        

        
        
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
    
}
