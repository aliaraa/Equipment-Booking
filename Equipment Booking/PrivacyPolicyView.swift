//
//  PrivacyPolicyView.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/10/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    
                    Text("Your privacy matters to us. Learn how we collect, use, and protect your information.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                
                // Innehåll
                ScrollView {
                    VStack(spacing: 16) {
                        PolicySection(
                            title: "Information We Collect",
                            content: "We collect personal information such as your name, email address, and rental preferences when you use our app. This helps us provide a tailored experience."
                        )
                        PolicySection(
                            title: "How We Use Your Data",
                            content: "Your data is used to process bookings, improve our services, and communicate with you. We may also use it for analytics to enhance user experience."
                        )
                        PolicySection(
                            title: "Data Protection",
                            content: "We implement security measures to protect your information from unauthorized access, including encryption and secure servers."
                        )
                        PolicySection(
                            title: "Sharing Your Information",
                            content: "We do not sell your personal data. It may be shared with service providers who assist us in operating the app, under strict confidentiality agreements."
                        )
                        PolicySection(
                            title: "Your Rights",
                            content: "You have the right to access, update, or delete your personal information. Contact us at support@equipmentbooking.com to exercise these rights."
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Privacy Policy")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// Hjälpkomponent för policycsektioner
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    PrivacyPolicyView()
}
