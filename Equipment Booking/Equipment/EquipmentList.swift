//
//  EquipmentList.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//


// We need to use FB database
// Added real-time listener for equipment updates

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
final class EquipmentDataManager: ObservableObject {
    @Published var toolData: [Tool] = []
    private let equipmentViewModel = EquipmentListingViewModel()
    private var listener: ListenerRegistration?  // For real-time updates
    
    init() {
        fetchEquipmentFromFirebase()
        listenForEquipmentUpdates()  // Start real-time listener
    }
    
    deinit {
        listener?.remove()  // Clean up listener
    }
    
    // Initial fetch from Firebase
    func fetchEquipmentFromFirebase() {
        Task {
            do {
                try await equipmentViewModel.fetchEquipments()
                DispatchQueue.main.async {
                    self.toolData = self.equipmentViewModel.equipments
                }
            } catch {
                print("Error fetching equipment from Firebase: \(error.localizedDescription)")
            }
        }
    }
    
    // Real-time listener for equipment updates
    func listenForEquipmentUpdates() {
        listener = Firestore.firestore().collection("equipments")
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error listening: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                self.toolData = snapshot.documents.compactMap { document in
                    try? Tool(from: document.data())
                }
            }
    }
}

