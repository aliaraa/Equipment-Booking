//
//  ConstructionView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct ConstructionView: View {
    var body: some View {
        CategoryView(category: "Construction", title: "Construction")
    }
}

#Preview {
    ConstructionView()
        .environmentObject(CartManager())
}
