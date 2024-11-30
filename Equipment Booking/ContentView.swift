//
//  ContentView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Spacer()
                    Text("Equipment A")
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
