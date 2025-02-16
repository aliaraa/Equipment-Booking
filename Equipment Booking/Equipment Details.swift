import SwiftUI

struct Equipment_Details: View {
    var tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @State private var selectPickupDate: Date? = nil
    @State private var selectReturnDate: Date? = nil
    @State private var isShowingDatePicker = false
    @State private var isPickingDate = true
    @State private var quantity: Int = 1
    @State private var showConfirmationAlert = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    func isWeekend(_ date: Date) -> Bool {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            return weekday == 1 || weekday == 7 // Söndag = 1, Lördag = 7
        }

    var isAddToCartEnabled: Bool {
        if let pickupDate = selectPickupDate, let returnDate = selectReturnDate {
            return pickupDate < returnDate
        }
        return false
    }

    var pickupDateBinding: Binding<Date> {
        Binding(
            get: { selectPickupDate ?? adjustedStartDate() },
            set: { selectPickupDate = $0 }
        )
    }

    var returnDateBinding: Binding<Date> {
        Binding(
            get: { selectReturnDate ?? (selectPickupDate ?? adjustedStartDate()) },
            set: { selectReturnDate = $0 }
        )
    }

    func isDateAvailable(_ date: Date) -> Bool {
        if cartManager.isWeekend(date) {
            return false
        }
        return !cartManager.getUnavailableDates(for: tool, quantity: quantity).contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
    }

    func findNextAvailableDate(after date: Date) -> Date {
        var nextDate = date
        var attempts = 0
        while (cartManager.isWeekend(nextDate) || !isDateAvailable(nextDate)) && attempts < 100 {
            nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate)!
            attempts += 1
        }
        return nextDate
    }

    func adjustedStartDate() -> Date {
        let today = Date()
        return findNextAvailableDate(after: today)
    }

    var body: some View {
        ZStack {
            VStack {
                Text(tool.name)
                    .font(.largeTitle)
                    .padding()

                if let imageUrlString = tool.imageURL, let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.title2)
                    Text(tool.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Price per day: \(tool.price, specifier: "%.2f") SEK")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()

                HStack {
                    Button("Pick Pickup Date") {
                        isPickingDate = true
                        isShowingDatePicker.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    Text(selectPickupDate != nil ? dateFormatter.string(from: selectPickupDate!) : "Select Date")
                }

                HStack {
                    Button("Pick Return Date") {
                        isPickingDate = false
                        isShowingDatePicker.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    Text(selectReturnDate != nil ? dateFormatter.string(from: selectReturnDate!) : "Select Date")
                }

                Spacer()

                Button("Add to Cart") {
                    let pickupDate = selectPickupDate ?? adjustedStartDate()
                    let returnDate = selectReturnDate ?? pickupDate

                    if pickupDate < returnDate {
                        cartManager.addToCart(tool, quantity: quantity, pickupDate: pickupDate, returnDate: returnDate)
                        showConfirmationAlert = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isAddToCartEnabled)
            }
            .padding()
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Added to Cart"),
                    message: Text(cartManager.confirmationMessage ?? "\(tool.name) has been added to your cart"),
                    dismissButton: .default(Text("OK"))
                )
            }

            if isShowingDatePicker {
                VStack {
                    DatePicker("Select Date", selection: isPickingDate ? pickupDateBinding : returnDateBinding, in: adjustedStartDate()..., displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .onChange(of: isPickingDate ? selectPickupDate : selectReturnDate) { newDate in
                            if let newDate = newDate, cartManager.isWeekend(newDate) {
                                if isPickingDate {
                                    selectPickupDate = findNextAvailableDate(after: newDate)
                                } else {
                                    selectReturnDate = findNextAvailableDate(after: newDate)
                                }
                            }
                        }

                    Button("Done") {
                        handleDateSelection(isPickingDate ? pickupDateBinding.wrappedValue : returnDateBinding.wrappedValue)
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

    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
            if let returnDate = selectReturnDate, returnDate < date {
                selectReturnDate = date
            }
        } else {
            selectReturnDate = date
            if let pickupDate = selectPickupDate, pickupDate > date {
                selectPickupDate = date
            }
        }
        isShowingDatePicker = false
    }
}
