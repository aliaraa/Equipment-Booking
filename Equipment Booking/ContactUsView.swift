//
//  ContactUsView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/10/25.
//

import SwiftUI
// Improvments for iPhone 14 view
// Used dynamic TextEditor heigh with minHeight
//Increase Vstack pacing to 24pt for the form section
// Add more padding to ContactInfoCard's Hstack
//Ensure button has 44x44 pt touch target.

struct ContactUsView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSendButtonActive: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView { // Wrap in ScrollView for long content
                VStack(spacing: 24) { // Increased spacing
                    VStack(spacing: 8) {
                        Text("Reach out with any questions or feedback.")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) {
                        ContactInfoCard(icon: "envelope.fill", title: "Email", detail: "equipmantester@gmail.com")
                        ContactInfoCard(icon: "phone.fill", title: "Phone", detail: "+46739984937")
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 16) { // Increased spacing
                        ProfileTextField(
                            icon: "person.fill",
                            placeholder: "Your Name",
                            text: $name,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                        ProfileTextField(
                            icon: "envelope.fill",
                            placeholder: "Your Email",
                            text: $email,
                            isEditable: true,
                            onEditingChanged: checkForChanges
                        )
                        TextEditor(text: $message)
                            .frame(minHeight: 120, maxHeight: 200) // Dynamic height
                            .padding(8)
                            .background(Color(white: 0.98))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                            .onChange(of: message) { _ in checkForChanges() }
                        
                        Button(action: sendMessage) {
                            Text("Send")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 44) // Ensure touch target
                                .padding(.vertical, 14)
                                .background(isSendButtonActive ? Color.blue : Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!isSendButtonActive)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func checkForChanges() {
        isSendButtonActive = !name.isEmpty && !email.isEmpty && !message.isEmpty
    }
    
    private func sendMessage() {
        print("Sending message from \(name) (\(email)): \(message)")
        name = ""
        email = ""
        message = ""
        isSendButtonActive = false
    }
}

struct ContactInfoCard: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack(spacing: 16) { // Increased spacing
            Image(systemName: icon)
                .foregroundColor(.blue.opacity(0.8))
                .font(.system(size: 20, weight: .medium))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(detail)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(16) // Increased padding
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

//struct ContactUsView: View {
//    @State private var name: String = ""
//    @State private var email: String = ""
//    @State private var message: String = ""
//    @State private var isSendButtonActive: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                // Header
//                VStack(spacing: 8) {
//                    
//                    Text("Reach out with any questions or feedback.")
//                        .font(.system(size: 16, design: .rounded))
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.leading)
//                }
//                .padding(.top, 20)
//                .padding(.horizontal, 16)
//                
//                // Kontaktinformation
//                VStack(spacing: 16) {
//                    ContactInfoCard(icon: "envelope.fill", title: "Email", detail: "equipmantester@gmail.com")
//                    ContactInfoCard(icon: "phone.fill", title: "Phone", detail: "+46739984937")
////                    ContactInfoCard(icon: "house.fill", title: "Address", detail: "123 Equipment St, Tech City")
//                }
//                .padding(.horizontal, 16)
//                
//                // Formulär
//                VStack(spacing: 12) {
//                    ProfileTextField(
//                        icon: "person.fill",
//                        placeholder: "Your Name",
//                        text: $name,
//                        isEditable: true,
//                        onEditingChanged: checkForChanges
//                    )
//                    
//                    ProfileTextField(
//                        icon: "envelope.fill",
//                        placeholder: "Your Email",
//                        text: $email,
//                        isEditable: true,
//                        onEditingChanged: checkForChanges
//                    )
//                    
//                    TextEditor(text: $message)
//                        .frame(height: 120)
//                        .padding(8)
//                        .background(Color(white: 0.98))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                        )
//                        .shadow(color: .gray.opacity(0.2), radius: 6)
//                        .onChange(of: message) { _ in checkForChanges() }
//                    
//                    Button(action: sendMessage) {
//                        Text("Send")
//                            .font(.system(size: 16, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 14)
//                            .background(isSendButtonActive ? Color.blue : Color.gray.opacity(0.5))
//                            .cornerRadius(12)
//                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
//                    }
//                    .disabled(!isSendButtonActive)
//                }
//                .padding(.horizontal, 16)
//                
//                Spacer()
//            }
//            .background(Color(.systemBackground))
//            .navigationTitle("Contact Us")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Contact Us")
//                        .font(.system(size: 22, weight: .bold, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//            }
//        }
//    }
//    
//    private func checkForChanges() {
//        isSendButtonActive = !name.isEmpty && !email.isEmpty && !message.isEmpty
//    }
//    
//    private func sendMessage() {
//        // Här kan du implementera logik för att skicka meddelandet, t.ex. till en backend eller Firebase
//        print("Sending message from \(name) (\(email)): \(message)")
//        name = ""
//        email = ""
//        message = ""
//        isSendButtonActive = false
//    }
//}
//
//// Kontaktinformationskort
//struct ContactInfoCard: View {
//    let icon: String
//    let title: String
//    let detail: String
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .foregroundColor(.blue.opacity(0.8))
//                .font(.system(size: 20, weight: .medium))
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold, design: .rounded))
//                    .foregroundColor(.primary)
//                Text(detail)
//                    .font(.system(size: 14, design: .rounded))
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
//    }
//}



#Preview {
    ContactUsView()
}
