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
        .font(Typography.body) // Use Typography for consistent styling
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
        .font(Typography.body) // Use Typography for consistent styling
    }
}

// ✅ Reusable Custom TextField Component
struct CustomProfileTextField: View {
    let placeholder: String
    @Binding var text: String
    let isEditable: Bool
    let showClearButton: Bool // ✅ New parameter for clear button
    let onEditingChanged: () -> Void
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onEditingChanged: { _ in onEditingChanged() })
                .font(Typography.body) // Use Typography for consistent styling
                .disabled(!isEditable)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
            
            if showClearButton && !text.isEmpty && isEditable { // ✅ Show clear button when typing
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
