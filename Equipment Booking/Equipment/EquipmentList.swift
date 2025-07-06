//
//  EquipmentList.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-30.
//


// We use FB database
// Added real-time listener for equipment updates
// Adapted to support server-side search with keywords

import Foundation
import Firebase
import FirebaseFirestore

@MainActor
final class EquipmentDataManager: ObservableObject {
    @Published var toolData: [Tool] = []
    private let equipmentViewModel = EquipmentListingViewModel()
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        Task {
            do {
                try await fetchEquipmentFromFirebase() // Initial fetch without search
            } catch {
                print("Error in initial fetch: \(error.localizedDescription)")
                // Continue despite error; listener will handle updates
            }
        }
        listenForEquipmentUpdates()
    }
    
    deinit {
        listener?.remove()
    }
    
      
    // Fetch equipment with optional search query and category
        func fetchEquipmentFromFirebase(searchText: String = "", category: String? = nil) async throws {
            let queryWords = searchText.lowercased().trimmingCharacters(in: .whitespaces)
                .split(separator: " ")
                .map { String($0) }
                .filter { $0.count > 2 } // Ignore short words
            
            var query: Query = db.collection("equipments")
            if let category = category {
                query = query.whereField("category", isEqualTo: category)
            }
            if !queryWords.isEmpty {
                query = query.whereField("keywords", arrayContainsAny: queryWords)
            }
            
            let snapshot = try await query.getDocuments()
            let fetchedTools = snapshot.documents.compactMap { document in
                try? Tool(from: document.data())
            }
            DispatchQueue.main.async {
                self.toolData = fetchedTools
            }
        }
    
    // Fetch equipment with optional search query
//    func fetchEquipmentFromFirebase(searchText: String = "") async throws {
//        let queryWords = searchText.lowercased().trimmingCharacters(in: .whitespaces)
//            .split(separator: " ")
//            .map { String($0) }
//            .filter { $0.count > 2 } // Ignore short words
//        let query = queryWords.isEmpty ? db.collection("equipments") :
//            db.collection("equipments").whereField("keywords", arrayContainsAny: queryWords)
//        let snapshot = try await query.getDocuments()
//        let fetchedTools = snapshot.documents.compactMap { document in
//            try? Tool(from: document.data())
//        }
//        DispatchQueue.main.async {
//            self.toolData = fetchedTools
//        }
//    }
    
    // Real-time listener for equipment updates (non-search)
    func listenForEquipmentUpdates() {
        listener = db.collection("equipments")
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

//@MainActor
//final class EquipmentDataManager: ObservableObject {
//    @Published var toolData: [Tool] = []
//    private let equipmentViewModel = EquipmentListingViewModel()
//    private var listener: ListenerRegistration?  // For real-time updates
//    
//    init() async {
//        await fetchEquipmentFromFirebase()
//        listenForEquipmentUpdates()  // Start real-time listener
//    }
//    
//    deinit {
//        listener?.remove()  // Clean up listener
//    }
//    
//    // Fetch equipment with optional search query
//    func fetchEquipmentFromFirebase(searchText: String = "") async throws {
//        let queryWords = searchText.lowercased().trimmingCharacters(in: .whitespaces)
//            .split(separator: " ")
//            .map { String($0) }
//            .filter { $0.count > 2 } // Ignore short words
//        let query = queryWords.isEmpty ? db.collection("equipments") :
//        db.collection("equipments").whereField("keywords", arrayContainsAny: queryWords)
//        let snapshot = try await query.getDocuments()
//        let fetchedTools = snapshot.documents.compactMap { document in
//            try? Tool(from: document.data())
//        }
//        DispatchQueue.main.async {
//            self.toolData = fetchedTools
//        }
//    }
//    
//    //    // Initial fetch from Firebase
//    //    func fetchEquipmentFromFirebase() {
//    //        Task {
//    //            do {
//    //                try await equipmentViewModel.fetchEquipments()
//    //                DispatchQueue.main.async {
//    //                    self.toolData = self.equipmentViewModel.equipments
//    //                }
//    //            } catch {
//    //                print("Error fetching equipment from Firebase: \(error.localizedDescription)")
//    //            }
//    //        }
//    //    }
//    
//    // Real-time listener for equipment updates
//    func listenForEquipmentUpdates() {
//        listener = Firestore.firestore().collection("equipments")
//            .addSnapshotListener { snapshot, error in
//                guard let snapshot = snapshot else {
//                    print("Error listening: \(error?.localizedDescription ?? "Unknown")")
//                    return
//                }
//                self.toolData = snapshot.documents.compactMap { document in
//                    try? Tool(from: document.data())
//                }
//            }
//    }
//    
//}

