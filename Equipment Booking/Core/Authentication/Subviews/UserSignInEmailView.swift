//
//  UserSignInEmailView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/9/24.
//

import SwiftUI


struct UserSignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        VStack{
            // Email TextField
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            //Passoword SecureField
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            // Forgot Password Navigation Link
            NavigationLink(destination: Text("Forgot Password View")){
                Text("Forgot Password")
                    .font(.footnote)
                    .foregroundColor(.blue)
                                             
                                             }
           //Sign In button
            Button{
                Task{
                    do{
                        try await viewModel.signUp()
                        showSignInView = false
                        return //if user exists
                    } catch{
                        print(error)
                        
                    }
                    
                    
                    do{
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch{
                        print(error)
                        
                    }
                    
                }
                
            }label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            // Spacer()
            
            
            
        }
        .padding()
//        .navigationTitle("Sign In With Email")
    }
}



struct SignInEmailViewModel_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                UserSignInEmailView(showSignInView: .constant(false))
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
