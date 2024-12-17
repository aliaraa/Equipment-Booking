//
//  Equipment_BookingApp.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct Equipment_BookingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            // ContentView()
            RootView () // To test authentication functions
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        // print("Configure Firebase Successfully!") // Check firebase config success
        return true
    }
}
