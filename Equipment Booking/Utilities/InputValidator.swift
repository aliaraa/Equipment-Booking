//
//  InputValidator.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import Foundation

struct ValidationHelper {
    
   // Validates email and returns an error message (or nil if valid)
    static func validateEmail(_ email: String) -> String? {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) ? nil : "Please enter a valid email address."
    }

    //Validates if passwords match and returns an error message (or nil if valid)
    static func validateConfirmPassword(password: String, confirmPassword: String) -> String? {
        return password == confirmPassword ? nil : "Passwords do not match."
    }
}

