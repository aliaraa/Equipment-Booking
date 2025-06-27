//
//  Views.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 6/28/25.
//

import Foundation
import SwiftUICore
import XCTest
import SwiftUI


//App-wide spacing and padding constants for consistent layout

enum Spacing: CGFloat {
    case small = 8
    case medium = 16
    case large = 24
    case extraLarge = 32
}


// Minimum touch targets

struct CustomButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    var body: some View {
        Button(action: action) {
            content
                .frame(minWidth: 44, minHeight: 44)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
