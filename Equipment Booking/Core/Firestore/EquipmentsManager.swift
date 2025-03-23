//
//  EquipmentsManager.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 1/6/25.
//

// EquipmentManager.swift
import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

@MainActor
final class EquipmentManager: ObservableObject {
    static let shared = EquipmentManager()
    private init() {}
    
    private let equipmentsCollection = Firestore.firestore().collection("equipments")
    private let rentalsCollection = Firestore.firestore().collection("rentals")
    
    private func equipmentDocument(equipmentId: String) -> DocumentReference {
        equipmentsCollection.document(equipmentId)
    }
    
    func uploadEquipment(tool: Tool) async throws {
        try equipmentDocument(equipmentId: tool.id).setData(from: tool, merge: false)
    }
    
    func getAllEquipments() async throws -> [Tool] {
        let snapshot = try await equipmentsCollection.getDocuments()
        var tools: [Tool] = []
        for document in snapshot.documents {
            let tool = try document.data(as: Tool.self)
            tools.append(tool)
        }
        return tools
    }
    
    func getNextAvailableDate(forToolId toolId: String) async throws -> Date {
        let snapshot = try await rentalsCollection
            .whereField("items.tool_id", arrayContains: toolId)
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        var latestReturnDate: Date = Date()
        for document in snapshot.documents {
            let rental = try document.data(as: Rental.self)
            if rental.returnDate > latestReturnDate {
                latestReturnDate = rental.returnDate
            }
        }
        return Calendar.current.date(byAdding: .day, value: 1, to: latestReturnDate) ?? latestReturnDate
    }
    
    func getToolAvailability(forToolId toolId: String, pickupDate: Date, returnDate: Date) async throws -> ([Rental], Int) {
        let equipmentSnapshot = try await equipmentDocument(equipmentId: toolId).getDocument()
        guard equipmentSnapshot.exists, let tool = try? equipmentSnapshot.data(as: Tool.self) else {
            throw NSError(domain: "EquipmentManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tool not found"])
        }
        let totalQuantity = tool.numberOfItems
        print("Total quantity for \(toolId): \(totalQuantity)")
        
        // Hämta alla aktiva bokningar
        let snapshot = try await rentalsCollection
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        print("Found \(snapshot.documents.count) active rentals to check for \(toolId)")
        
        var relevantBookings: [Rental] = []
        var dailyAvailability: [Date: Int] = [:]
        let calendar = Calendar.current
        
        // Normalisera datum till början av dagen
        let pickupStart = calendar.startOfDay(for: pickupDate)
        let returnEnd = calendar.startOfDay(for: returnDate)
        
        // Fyll i daglig tillgänglighet
        var currentDate = pickupStart
        while currentDate <= returnEnd {
            dailyAvailability[currentDate] = totalQuantity
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Analysera bokningar
        for document in snapshot.documents {
            let rental = try document.data(as: Rental.self)
            let overlaps = rental.pickupDate <= returnEnd && rental.returnDate >= pickupStart
            print("Rental \(document.documentID): pickup \(dateFormatter.string(from: rental.pickupDate)), return \(dateFormatter.string(from: rental.returnDate)), overlaps: \(overlaps)")
            
            if overlaps, let bookedItem = rental.items.first(where: { $0.id == toolId }) {
                relevantBookings.append(rental)
                currentDate = calendar.startOfDay(for: rental.pickupDate)
                let rentalEnd = calendar.startOfDay(for: rental.returnDate)
                while currentDate <= rentalEnd {
                    if let available = dailyAvailability[currentDate], currentDate >= pickupStart && currentDate <= returnEnd {
                        dailyAvailability[currentDate] = max(0, available - bookedItem.quantity)
                        print(" - Adjusted \(dateFormatter.string(from: currentDate)) to \(dailyAvailability[currentDate]!) due to \(bookedItem.quantity) booked")
                    }
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                }
            }
        }
        
        let minAvailable = dailyAvailability.values.min() ?? totalQuantity
        print("Daily availability: \(dailyAvailability.map { "\(dateFormatter.string(from: $0.key)): \($0.value)" }.joined(separator: ", "))")
        print("Minimum available for \(toolId) from \(dateFormatter.string(from: pickupStart)) to \(dateFormatter.string(from: returnEnd)): \(minAvailable)")
        return (relevantBookings, minAvailable)
    }
    
    func generateBookingID(firstName: String, lastName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let dateStr = dateFormatter.string(from: Date())
        return "\(firstName.prefix(1))\(lastName.prefix(2).uppercased())\(dateStr)"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
