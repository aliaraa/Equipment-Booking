import SwiftUI

struct ContentView: View {
    @State var selectPickupDate: Date = Date()
    @State var selectReturnDate: Date = Date()
    @State var isShowingDatePicker = false
    @State var isPickingDate = true
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Equipment Details")
                    .font(.largeTitle)
                    .padding()

                Image(systemName: "globe")
                    .frame(width: 400.0, height: 400.0)
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .background(Color.black)

                HStack {
                    VStack {
                        Text("Equipment")
                            .font(.title)
                    }

                    Spacer()
                    VStack {
                        HStack {
                            Button("-") {
                                // Decrease equipment count logic
                            }
                            Text("1")
                                .font(.headline)
                                .padding(10)
                            Button("+") {
                                // Increase equipment count logic
                            }
                        }

                        HStack {
                            Button("Pick Pickup Date") {
                                isPickingDate = true
                                isShowingDatePicker.toggle()
                            }
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Text(dateFormatter.string(from: selectPickupDate))
                                .padding(.horizontal)
                                .font(.subheadline)
                                .foregroundColor(.black)

                            Button("Pick Return Date") {
                                isPickingDate = false
                                isShowingDatePicker.toggle()
                            }
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Text(dateFormatter.string(from: selectReturnDate))
                                .padding(.horizontal)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding()

                Text("Description")
                    .font(.headline)
                    .padding()

                Spacer()

                Button("Add to cart") {
                    // Logic for adding to cart
                }
                .frame(width: 200.0, height: 50.0)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .padding()

            // DatePicker overlay
            if isShowingDatePicker {
                VStack {
                    Text(isPickingDate ? "Select Pickup Date" : "Select Return Date")
                        .font(.title2)
                        .padding(.bottom)
                        .foregroundColor(Color.white)

                    DatePicker(isPickingDate ? "Select Pickup Date" : "Select Return Date",
                        selection: isPickingDate ? $selectPickupDate : $selectReturnDate,
                        in: Date.now..., // Ensure no past dates can be selected
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)

                    Button("Done") {
                        isShowingDatePicker = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .ignoresSafeArea()
            }
        }
        .onChange(of: selectPickupDate) { newValue, oldValue in
            // När pickup datum ändras, säkerställ att retur datum är senare
            if selectPickupDate > selectReturnDate {
                selectReturnDate = selectPickupDate
            }
        }
        .onChange(of: selectReturnDate) { newValue, oldValue in
            // När retur datum ändras, säkerställ att retur datum är senare än pickup datum
            if selectReturnDate < selectPickupDate {
                selectPickupDate = selectReturnDate
            }
        }
    }
}

#Preview {
    ContentView()
}
