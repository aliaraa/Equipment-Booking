import Foundation
import Combine

// MARK: - CartManager
class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var bookings: [Booking] = []
    @Published var unavailableMessage: String? = nil
    @Published var confirmationMessage: String? = nil

    // Beräknad egenskap för totalpriset
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.tool.price * Double($1.quantity)) }
    }

    // Lägger till verktyg i kundvagnen
    func addToCart(_ tool: Tool, quantity: Int, pickupDate: Date, returnDate: Date) {
        resetUnavailableMessage()
        resetConfirmationMessage()
        
        // Kontrollera om verktyget är tillgängligt under valt datum
        if !isToolAvailable(tool, from: pickupDate, to: returnDate, quantity: quantity) {
            let nextAvailableDate = getNextAvailableDate(for: tool)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            unavailableMessage = "This tool is unavailable during the selected dates. It will be available from \(dateFormatter.string(from: nextAvailableDate))."
            return
        }

        // Om verktyget redan finns i kundvagnen, uppdatera kvantiteten
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            let newQuantity = cartItems[index].quantity + quantity
            if newQuantity > tool.numberOfItems {
                unavailableMessage = "Sorry, only \(tool.numberOfItems) items are available for \(tool.name)."
                return
            }
            cartItems[index].quantity = newQuantity
        } else {
            cartItems.append(CartItem(tool: tool, quantity: quantity, pickupDate: pickupDate, returnDate: returnDate))
        }

        // Skapa en bekräftelsemeddelande
        confirmationMessage = "\(tool.name) (\(quantity)) added to cart."
        
        // Lägg till bokningen
        let newBooking = Booking(toolId: tool.id, userId: "CURRENT_USER_ID", startDate: pickupDate, endDate: returnDate, quantity: quantity)
        bookings.append(newBooking)
    }

    // Uppdatera kvantiteten för ett verktyg i kundvagnen
    func updateQuantity(for tool: Tool, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.tool.id == tool.id }) {
            let currentQuantity = cartItems[index].quantity
            let newQuantity = quantity

            // Se till att vi inte försöker sätta en kvantitet som är under 1
            if newQuantity <= 0 {
                cartItems.remove(at: index)
                return
            }

            // Se till att kvantiteten inte överstiger tillgänglig lagermängd
            if newQuantity > tool.numberOfItems {
                unavailableMessage = "Sorry, only \(tool.numberOfItems) items are available for \(tool.name)."
                return
            }

            // Uppdatera kvantiteten
            cartItems[index].quantity = newQuantity
        }
    }

    // Kontrollera om verktyget är tillgängligt för vald period
    func isToolAvailable(_ tool: Tool, from startDate: Date, to endDate: Date, quantity: Int) -> Bool {
        let totalBooked = bookings
            .filter { $0.toolId == tool.id && !($0.endDate < startDate || $0.startDate > endDate) }
            .reduce(0) { $0 + $1.quantity }
        
        return (totalBooked + quantity) <= tool.numberOfItems
    }

    // Hämta nästa lediga datum
    func getNextAvailableDate(for tool: Tool) -> Date {
        let sortedBookings = bookings
            .filter { $0.toolId == tool.id }
            .sorted { $0.endDate < $1.endDate }
        
        return sortedBookings.last?.endDate ?? Date()
    }

    // Återställ felmeddelande
    func resetUnavailableMessage() {
        unavailableMessage = nil
    }

    // Återställ bekräftelsemeddelande
    func resetConfirmationMessage() {
        confirmationMessage = nil
    }

    // Ta bort från kundvagnen
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    // Ta bort bokning vid borttagning av varor från kundvagnen
    func removeBooking(for tool: Tool) {
        bookings.removeAll { $0.toolId == tool.id }
    }
    
    // Rensa kundvagnen
    func clearCart() {
        cartItems.removeAll()
    }
    
    func getUnavailableDates(for tool: Tool, quantity: Int) -> [Date] {
        let bookedDates = bookings
            .filter { $0.toolId == tool.id }
            .flatMap { booking in
                Calendar.current.generateDates(from: booking.startDate, to: booking.endDate)
            }
        
        let dateCounts = Dictionary(bookedDates.map { ($0, 1) }, uniquingKeysWith: +)
        
        let unavailableDates = dateCounts
            .filter { $0.value + quantity > tool.numberOfItems }
            .map { $0.key }
        
        return unavailableDates
    }
    
}
