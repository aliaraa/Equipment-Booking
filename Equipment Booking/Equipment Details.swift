import SwiftUI

struct Equipment_Details: View {
    var tool: Tool
    @EnvironmentObject var cartManager: CartManager
    @State private var selectPickupDate: Date = Date()
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
    
    var isAddToCartEnabled: Bool {
        if let returnDate = selectReturnDate {
            return selectPickupDate < returnDate
        }
        return false
    }
    
    // Helper function to get next available date based on the current selection
    func handleDateSelection(_ date: Date) {
        if isPickingDate {
            selectPickupDate = date
            if let returnDate = selectReturnDate, returnDate < selectPickupDate {
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
    
    // Check if the date is available with the current quantity
    func isDateAvailable(_ date: Date) -> Bool {
        return !cartManager.getUnavailableDates(for: tool, quantity: quantity).contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
    }
    
    // Function to check if the date is a weekend
    func isWeekend(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    // Function to find the next available date automatically
    func findNextAvailableDate(from startDate: Date) -> Date {
        var nextAvailableDate = startDate
        // Loop through dates until a valid, non-weekend, available date is found
        while !isDateAvailable(nextAvailableDate) || isWeekend(nextAvailableDate) {
            nextAvailableDate = Calendar.current.date(byAdding: .day, value: 1, to: nextAvailableDate)!
        }
        return nextAvailableDate
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
                        ProgressView()  // Loading indicator
                    }
                } else {
                    Image(systemName: "photo")  // Placeholder image
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
                    Text(dateFormatter.string(from: selectPickupDate))
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
                    cartManager.addToCart(tool, quantity: quantity, pickupDate: selectPickupDate, returnDate: selectReturnDate!)
                    showConfirmationAlert = true
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
                    DatePicker("Select Date", selection: isPickingDate ? $selectPickupDate : Binding(
                        get: { selectReturnDate ?? Date() },
                        set: { selectReturnDate = $0 }
                    ), in: Date.now..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .onChange(of: selectPickupDate) { newDate in
                        // If selected date is unavailable or a weekend, find the next available date
                        if !isDateAvailable(newDate) || isWeekend(newDate) {
                            selectPickupDate = findNextAvailableDate(from: newDate)
                        }
                    }
                    
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
    id: "LCE-CM-11",
    name: "Petrol-powered mobile cutters, plates 400-500mm",
    category: "Construction",
    mainCategory: "Light construction equipment",
    subCategory: "Cutting machines",
    description: "The mobile petrol cutter with a 500 mm blade is used for cutting asphalt or concrete surfaces using diamond blades.",
    manufacturer: "Ntc",
    imageName: "B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
    imageURL: "https://storage.googleapis.com/equipment-management-db.firebasestorage.app/Equipment_imgs/B546r2T9p0R0M1y6l8j7q4K2a7b6K0M5.webp",
    status: "available",
    price: 100.0,
    numberOfItems: 1,
    isAvailable: true
)

#Preview {
    Equipment_Details(tool: exampleTool)
        .environmentObject(CartManager())
}
