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
                    Text("EquipRent Privacy Policy")
//                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .font(Typography.largeTitle)  // Use Typography for consistent styling
                        .foregroundColor(.primary)
                    
                    // NEW: Dedicated Last Updated Date Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Updated: May 27, 2025")
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .font(Typography.subheadline)  // Use Typography for consistent styling
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    
                    Text("EquipRent (\"we,\" \"us\") respects your privacy. This Privacy Policy explains how we collect, use, and protect your data when you use our app.")
//                        .font(.system(size: 16, design: .rounded))
                        .font(Typography.body)  // Use Typography for consistent styling
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                                               
                        // Policy Sections
                        PolicySection(
                            title: "Educational Purpose and Pricing Disclaimer",
                            content: """
                            This app is designed solely for educational and demonstration purposes. The equipment listed, including all tools and their associated prices, is virtual and not available for actual rental or purchase. Prices displayed within the app (e.g., SEK/day) are for illustrative purposes only and do not represent real-world transactions. No payments are processed through this app, and no financial transactions are required or supported.
                            """
                        )
                        
                        
                        PolicySection(
                            title: "Data We Collect",
                            content: """
                            - **Personal Info**: Email and name (via Google Sign-In or email login) to manage your account.
                            - **Usage Data**: App interactions (e.g., searches, bookings) to improve our service (via Firebase Analytics).
                            - **Device Info**: Device type and OS version for compatibility, and FCM tokens for push notifications and compatibility.
                            """
                        )
                        PolicySection(
                            title: "How We Use Your Data",
                            content: """
                            - To provide app features (e.g., booking cranes, managing rentals).
                            - To personalize your experience (e.g., showing your profile).
                            - To analyze usage and improve EquipRent.
                            - To comply with legal obligations.
                            """
                        )
                        PolicySection(
                            title: "Data Sharing",
                            content: """
                            - We use Firebase (Google) for authentication and analytics, which may process data per their policies.Please review Firebase's privacy policy for more information on how your data is handled.
                            - We don’t share your data with third parties.
                            """
                        )
                        PolicySection(
                            title: "Data Security",
                            content: """
                            - We use encryption to protect your data.
                            - Firebase follows industry-standard security practices.
                            """
                        )
                        PolicySection(
                            title: "5. Your Rights",
                            content: """
                            - Access, update, or delete your data via your profile or by emailing support@equiprent.com.
                            - EU users: GDPR rights apply (e.g., data portability).
                            - Users can delete their account from Firebase Authentication via Profile > Delete Account. This removes access to the account but preserves user and rental data in our database for record-keeping. All records will be anonymized after 30 days.
                            """
                        )
                        PolicySection(
                            title: "6. Contact Us",
                            content: """
                            - **Email**: equipmantester@gmail.com
                            - **See our Support page**: https://sites.google.com/view/equiprent-assist
                            """
                        )
                        
                        // Link to online policy page
                        Link(destination: URL(string: "https://sites.google.com/view/equip-rent-privacy/home")!) {
                            Text("View Online Privacy Policy")
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .font(Typography.headline)  // Use Typography for consistent styling
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Privacy Policy")
            .font(Typography.title)  // Use Typography for consistent styling
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// Helper component for policy sections
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
//                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .font(Typography.headline)  // Use Typography for consistent styling
                .foregroundColor(.primary)
            
            Text(content)
                .font(Typography.body)  // Use Typography for consistent styling
//                .font(.system(size: 16, design: .rounded))
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
