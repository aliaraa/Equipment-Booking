//
//  ProfileMenuView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/5/24.
//

import SwiftUI

struct ProfileMenuView: View {
    @Binding var isMenuOpen: Bool // Track the menu visibility from the parent
    
    var body: some View {
        VStack {
            // Spacer to push everything down
            Spacer()
                .frame(height: 30) //
            
            // Back Button and Profile Image
            HStack {
                Button(action: {
                    withAnimation {
                        isMenuOpen = false // Close the menu
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.leading, 20)
                }
                Spacer()
                
                // Profile Image (Centered)
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    // .padding(.top, 5) // Add extra padding to space it out more
                
                Spacer()
                
                // Shopping Cart Icon
                Button(action: {
                    // Action for shopping cart icon )
                    print("Shopping Cart tapped")
                }) {
                    Image(systemName: "cart")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.trailing, 20) // Align with the chevron button
                }
                        
                
            }
            
            
            //.padding(.bottom, 30)
            
            
            // Menu List with Dividers and Raised Effect
            VStack(spacing: 5) { // Use 0 spacing to create clean divider placement
                MenuItem(icon: "person", text: "Account", action: {})
                // Divider()
                MenuItem(icon: "bell", text: "Notifications", action: {})
                //Divider()
                MenuItem(icon: "gearshape", text: "Settings", action: {})
                //Divider()
                MenuItem(icon: "questionmark.circle", text: "Support", action: {})
            }
            .padding(.top, 30)
            .padding(.horizontal, 10)
            
            
            
            // Sign Out Button
            Button(action: {
                withAnimation {
                    isMenuOpen = false // Close the menu
                }
                print("Signed out and navigated back to home.")
            }) {
                HStack {
                    Image(systemName: "arrow.backward.square")
                        .font(.headline)
                    Text("Sign Out")
                        .fontWeight(.bold)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            Spacer()
            
        }
    }
}

// Reusable Menu Item View with Action Support
struct MenuItem: View {
    let icon: String
    let text: String
    let action: () -> Void // Closure for button action
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow for raised effect
                            ) // Subtle shadow for raised effect
            
        }
        .padding(.horizontal, 10) // Add horizontal padding to ensure items don't touch the screen edge
    }
}

#Preview {
    // Creating a Binding to pass into the ProfileMenuView
    ProfileMenuView(isMenuOpen: .constant(true)) // Use .constant(true) for the preview
}
