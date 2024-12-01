//
//  ContentView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Development")
        }
        .padding()
        Equipment_Details()
    }
}

#Preview {
    ContentView()
}
