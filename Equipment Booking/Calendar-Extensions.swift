//
//  Calendar-Extensions.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2025-02-16.
//

import Foundation

extension Calendar {
    // Genererar alla datum mellan två datum
    func generateDates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        // Hämta alla datum från startDate till endDate
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}
