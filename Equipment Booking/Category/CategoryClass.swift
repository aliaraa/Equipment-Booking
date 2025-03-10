//
//  CategoryClass.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-12-16.
//

import Foundation

class Category: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    
    init(title: String, description: String) {
        self.id = UUID()
        self.title = title
        self.description = description
    }
}
