import SwiftUI

struct Equipment_Details: View {
    var tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @State private var selectPickupDate: Date = Date()
    @State private var selectReturnDate: Date? = nil
    @State private var isShowingDatePicker = false
    @State private var isPickingDate = true
    @State private var quantity: Int = 1
    @State private var showConfirmation = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var isAddToCartEnabled: Bool {
            if var returnDate = selectReturnDate {
                return selectPickupDate < returnDate
            }
            return false
        }

    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
            if var returnDate = selectReturnDate, returnDate < selectPickupDate {
                selectReturnDate = selectPickupDate
            }
        } else {
            selectReturnDate = date
            if selectPickupDate > date {
                selectPickupDate = date
            }
        }
        isShowingDatePicker = false
    }

    var body: some View {
        ZStack {
            VStack {
                Text(tool.name)
                    .font(.largeTitle)
                    .padding()

                Image(systemName: "hammer.fill")
                    .frame(width: 400.0, height: 300.0)
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .background(Color.black)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.title)
                        Text(tool.description)
                            .padding(.trailing)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        Text("Price per day: \(tool.price) SEK")
                            .font(.headline)
                            .foregroundColor(Color.red)
                            .padding([.top, .bottom, .trailing])
                    }
                    .padding(.leading)

                    Spacer()
                    VStack {
                        HStack {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }

                            Text("\(quantity)")
                                .font(.title3)
                                .padding(10)

                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                    }.padding(.trailing)
                }

                VStack {
                    HStack {
                        Button("Pick Pickup Date") {
                            isPickingDate = true
                            isShowingDatePicker.toggle()
                        }
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Spacer()
                        Text(dateFormatter.string(from: selectPickupDate))
                            .padding(.horizontal)
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }

                    HStack {
                        Button("Pick Return Date") {
                            isPickingDate = false
                            isShowingDatePicker.toggle()
                        }
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Spacer()
                        if var returnDate = selectReturnDate {
                            Text(dateFormatter.string(from: returnDate))
                                .padding(.horizontal)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        } else {
                            Text("Select Date")
                                .italic()
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    }
                }
                .padding(.leading)

                Spacer()

                Button(action: {
                    if var returnDate = selectReturnDate {
                        cartManager.addToCart(tool, quantity: quantity)
                        showConfirmation = true
                    }
                }) {
                    Text("Add to Cart")
                        .frame(width: 200.0, height: 50.0)
                        .background(isAddToCartEnabled ? Color.green : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!isAddToCartEnabled)
                .padding()
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Added to Cart"),
                        message: Text("\(quantity) x \(tool.name) added to your cart."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding()

            if isShowingDatePicker {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: isPickingDate ? $selectPickupDate : Binding(
                            get: {selectReturnDate ?? Date()},
                            set: {selectReturnDate = $0}
                        ),
                        in: Date.now...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)

                    Button("Done") {
                        handleDateSelection(isPickingDate ? selectPickupDate : (selectReturnDate ?? Date()))
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
            }
        }
    }
}
let exampleTool = Tool(
    name: "Hammer",
    description: "A sturdy hammer for construction work.",
    price: 15,
    isAvailable: true,
    category: "Construction"
)
#Preview {
    Equipment_Details(tool: exampleTool)
        .environmentObject(CartManager())
}
