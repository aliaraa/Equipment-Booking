//
//  ElectricalView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct ElectricalView: View {
    var body: some View {
        CategoryView(category: "Electrical", title: "Electrical")
    }
}

#Preview {
    ElectricalView()
        .environmentObject(CartManager())
}
