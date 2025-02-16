//
//  FirebaseBooking.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-02-12.
//

import Firebase
import Foundation
import FirebaseFirestore

@MainActor
final class FirebaseBookingManager: ObservableObject {
    @Published var bookings: [Booking] = []
    
    private let db = Firestore.firestore()
    
    init() {
        fetchBookingsFromFirebase()
    }
    
    func fetchBookingsFromFirebase() {
        db.collection("bookings").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching bookings: \(error.localizedDescription)")
                return
            }
            
            self.bookings = snapshot?.documents.compactMap { document in
                let data = document.data()
                return Booking(
                    id: document.documentID,
                    toolId: data["toolId"] as? String ?? "",
                    userId: data["userId"] as? String ?? "",
                    startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                    endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                    quantity: data["quantity"] as? Int ?? 1
                )
            } ?? []
        }
    }
    
    func addBookingToFirebase(toolId: String, startDate: Date, endDate: Date, quantity: Int) {
        let bookingData: [String: Any] = [
            "toolId": toolId,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "quantity": quantity
        ]
        
        db.collection("bookings").addDocument(data: bookingData) { error in
            if let error = error {
                print("Error adding booking: \(error.localizedDescription)")
            } else {
                print("Booking added successfully.")
                self.fetchBookingsFromFirebase()
            }
        }
    }
}
