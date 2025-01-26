//
//  CartView.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-01-05.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        List {
            ForEach(cartManager.cartItems) { cartItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(cartItem.tool.name)
                            .font(.headline)
                        Text("Price: \(cartItem.tool.price) SEK")
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            cartManager.updateQuantity(for: cartItem.tool, quantity: cartItem.quantity - 1)
                        }) {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        
                        Text("\(cartItem.quantity)")
                            .padding(.horizontal)
                        Button(action: {
                            cartManager.updateQuantity(for: cartItem.tool, quantity: cartItem.quantity + 1)
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    
                }
            }
            .onDelete { offsets in
                cartManager.removeFromCart(at: offsets)
            }
        }
        .navigationTitle("Cart")
    }
}


#Preview {
    Equipment_Details(tool: exampleTool)
        .environmentObject(CartManager()) 
}



