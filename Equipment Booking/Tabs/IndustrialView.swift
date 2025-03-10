//
//  IndustrialView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct IndustrialView: View {
    var body: some View {
        CategoryView(category: "Industrial", title: "Industrial")
    }
}

#Preview {
    IndustrialView()
        .environmentObject(CartManager())
}
