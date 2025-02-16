import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var alertMessage: AlertMessage?
    @State private var isShowingConfirmation = false
   

    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }

    // Hjälpfunktion för att formatera datum
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.cartItems.isEmpty {
                    VStack {
                        Text("Your cart is empty")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()

                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(cartManager.cartItems) { cartItem in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(cartItem.tool.name)
                                        .font(.headline)
                                    Text("Price: \(cartItem.tool.price, specifier: "%.2f") SEK")
                                        .foregroundColor(Color.gray)

                                    // Visa hyresdatum med den formaterade funktionen
                                    let pickupDate = formatDate(cartItem.pickupDate)
                                    let returnDate = formatDate(cartItem.returnDate)
                                    Text("Pickup: \(pickupDate) - Return: \(returnDate)")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
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
                        }
                        .onDelete { offsets in
                            cartManager.removeFromCart(at: offsets)
                        }
                    }

                    // Visa totalpris
                    Text("Total: \(cartManager.totalPrice, specifier: "%.2f") SEK")
                        .font(.title2)
                        .padding()

                    // Checkout-knapp
                    NavigationLink(destination: ConfirmationView(), isActive: $isShowingConfirmation) {
                        Button(action: {
                            isShowingConfirmation = true
                            
                        }) {
                            Text("Checkout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cart")
            .onReceive(cartManager.$unavailableMessage.compactMap { $0 }) { message in
                alertMessage = AlertMessage(message: message)
                cartManager.resetUnavailableMessage()
            }
            .alert(item: $alertMessage) { alert in
                Alert(
                    title: Text("Notification"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

