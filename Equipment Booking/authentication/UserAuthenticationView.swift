//
//  UserAuthenticationView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/8/24.
//

import SwiftUI

struct UserAuthenticationView: View {
    var body: some View {
        VStack{
            NavigationLink{
                Text("Hello!")
            } label: {
                Text("Sign in With Email")
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
        .navigationTitle("Sign in")
    }
}


struct UserAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            NavigationStack{
                UserAuthenticationView()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

//#Preview {
//    UserAuthenticationView()
//}
