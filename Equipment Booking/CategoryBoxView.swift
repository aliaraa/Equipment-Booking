//
//  CategoryBoxView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

import SwiftUI

struct CategoryBoxView: View {
    @State var category: Category
    var body: some View {
        
            VStack {
                Text(category.title)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Spacer()
                Text(category.description)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
            .border(Color.black)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}

#Preview {
    CategoryBoxView(category: Category(title: "Books", description: "Find your favorite books"))
        .environmentObject(CartManager())
}
