//
//  ContentView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-24.
//

import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false // Track menu visibility
    @State private var searchText = "" // Track the search text
    
    var body: some View {
        ZStack {
            // Main Content View
            VStack {
                // Spacer to push everything down
                Spacer()
                    .frame(height: 30) // Adjust height
                
                // Hamburger Menu Button (Upper-right corner)
                HStack {
                    Spacer() // Push the hamburger icon to the right
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle() // Toggle the menu visibility
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.gray)
                            .font(.title)
                            .padding()
                    }
                }
                
                // Search and Filter Bar (20pt below the hamburger button)
                HStack {
                    // Search Text Field
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.4)))
                        .frame(height: 40)
                    
                    // Close (X) Button to Clear the Search Field
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = "" // Clear the search text
                        }) {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 10)
                    }
                    
                    // Filter Button (with 10pt gap from the search field)
                    Button(action: {
                        // Handle filter action here
                        print("Filter button tapped")
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                }
                .padding(.top, 20) // Space between the hamburger button and the search/filter bar
                .padding(.horizontal, 20)
                
                Spacer() // Keep the rest of the screen empty
            }
            .background(Color.white)
            
            // Present the Menu Screen when the menu is open
            if isMenuOpen {
                ProfileMenuView(isMenuOpen: $isMenuOpen)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .transition(.move(edge: .trailing)) // Slide-in effect
                    .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



