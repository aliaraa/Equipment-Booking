import Foundation

// MARK: - BookingManager
class BookingManager: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var unavailableMessage: String?

    func addBooking(toolId: String, userId: String, startDate: Date, endDate: Date, quantity: Int, totalAvailable: Int) {
        if isToolAvailable(toolId: toolId, startDate: startDate, endDate: endDate, userId: userId, requestedQuantity: quantity, totalAvailable: totalAvailable) {
            let newBooking = Booking(toolId: toolId, userId: userId, startDate: startDate, endDate: endDate, quantity: quantity)
            bookings.append(newBooking)
        }
    }

    func isToolAvailable(toolId: String, startDate: Date, endDate: Date, userId: String, requestedQuantity: Int, totalAvailable: Int) -> Bool {
        var totalBooked = 0
        
        for booking in bookings where booking.toolId == toolId {
            // Kolla om användaren redan har bokat verktyget under perioden
            if booking.userId == userId && ((startDate >= booking.startDate && startDate < booking.endDate) || (endDate > booking.startDate && endDate <= booking.endDate)) {
                unavailableMessage = "Du har redan bokat detta verktyg under denna period."
                return false
            }

            // Kontrollera om verktyget är bokat av andra under perioden och räkna hur många är bokade
            if (startDate < booking.endDate && endDate > booking.startDate) {
                totalBooked += booking.quantity
            }
        }
        
        // Kontrollera om det finns tillräckligt med verktyg kvar
        if totalBooked + requestedQuantity > totalAvailable {
            let nextAvailableDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium

            unavailableMessage = "Det finns inte tillräckligt många verktyg tillgängliga under vald period. Nästa möjliga bokning är från \(dateFormatter.string(from: nextAvailableDate))."
            return false
        }
        
        // Verktyget är tillgängligt
        unavailableMessage = nil
        return true
    }
}
