//
//  ContentView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if #available(iOS 18.0, *) {
            TabsView()
        } else {
            // Fallback on earlier versions
        }
      
    }
}

#Preview {
    ContentView()
        .environmentObject(CartManager())
}
