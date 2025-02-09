//
//  Equipment_BookingApp.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-24.
//

import SwiftUI
import FirebaseCore

@main
struct Equipment_BookingApp: App {
    @StateObject private var cartManager = CartManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            CategoryView(category: "Construction", title: "Construction")
//            ContentView()
                .environmentObject(cartManager)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()  // call config
 
        if FirebaseApp.app() == nil
        {
            print("Firebase initialisation failed!")
        } else {
            if let apiKey = FirebaseApp.app()?.options.apiKey {
//                print("Firebase API Key Used: \(apiKey)")
            }
        }
        return true
 
    }
}


