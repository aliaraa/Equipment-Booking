//
//  Equipment_BookingApp.swift
//  Equipment Booking
//
//  Created by Ali Ara on 2024-11-24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import UIKit


@main
struct Equipment_BookingApp: App {
    @StateObject private var cartManager = CartManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 18.0, *) {
                RootView()
                    .environmentObject(cartManager)
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    #if targetEnvironment(simulator)
                    self.simulateNotification()
                    #endif
                }
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        if FirebaseApp.app() == nil {
            print("Firebase initialisation failed!")
        } else if let apiKey = FirebaseApp.app()?.options.apiKey {
            print("Firebase API Key Used: \(apiKey)")
        }
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid ?? "test_user_id"
        db.collection("users").document(userId).setData(["fcmToken": token], merge: true) { error in
            if let error = error {
                print("Error saving FCM token: \(error)")
            } else {
                print("FCM Token saved: \(token)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let rentalId = userInfo["rentalId"] as? String {
            print("Tapped notification for rental: \(rentalId)")
            let db = Firestore.firestore()
            db.collection("rentals").document(rentalId).updateData(["notification_opened": true]) { error in
                if let error = error {
                    print("Error marking notification opened: \(error)")
                } else {
                    print("Notification opened recorded for rental: \(rentalId)")
                }
            }
        }
        completionHandler()
    }
    
    private func simulateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rental Due Soon"
        content.body = "Your rental (Screwdriver, Pliers) is due on 2025-04-07T12:00:00Z"
        content.sound = .default
        content.userInfo = ["rentalId": "testRental1"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Local notification error: \(error)")
            }
        }
        
        let db = Firestore.firestore()
        let notificationData: [String: Any] = [
            "title": content.title,
            "body": content.body,
            "rentalId": "testRental1",
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        db.collection("users").document("test_user_id").collection("notifications")
            .addDocument(data: notificationData) { error in
                if let error = error {
                    print("Error adding mock notification: \(error)")
                } else {
                    print("Mock notification added")
                }
            }
        // Mock rental aligned with Rental struct
        db.collection("rentals").document("testRental1").setData([
            "id": "testRental1",
            "user_id": "test_user_id",
            "items": [
                ["tool_id": "Screwdriver", "quantity": 1],
                ["tool_id": "Pliers", "quantity": 1]
            ],
            "pickup_date": Timestamp(date: Date()),
            "return_date": Timestamp(date: Date(timeIntervalSinceNow: 24 * 60 * 60)),
            "status": "active",
            "notification_sent": true,
            "notification_opened": false
        ], merge: true) { error in
            if let error = error {
                print("Error setting mock rental data: \(error)")
            } else {
                print("Mock rental data set successfully")
            }
        }
    }
}
