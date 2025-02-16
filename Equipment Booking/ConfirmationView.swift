//
//  ConfirmationView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-02-15.
//

import SwiftUI

struct ConfirmationView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding()

            Text("Thank you for your order!")
                .font(.title)
                .padding()

            Text("Your order has been successfully placed.")
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            NavigationLink(destination: CartView()) {
                Text("Back to Cart")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .navigationTitle("Order Confirmation")
        .onAppear {
            cartManager.clearCart()
        }
    }
}

