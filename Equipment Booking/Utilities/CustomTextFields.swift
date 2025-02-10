//
//  CustomTextFields.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 2/9/25.
//

import SwiftUI

// Custom TextField
struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 2))
        .background(Color.clear)
        .foregroundColor(Color(UIColor.darkGray))
    }
}

// Custom SecureField with Toggle
struct CustomSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var toggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            Button(action: toggle) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 2))
        .background(Color.clear)
        .foregroundColor(Color(UIColor.darkGray))
    }
}
