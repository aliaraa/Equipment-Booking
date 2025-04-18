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
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cartManager)
                .environmentObject(authViewModel)
                .environmentObject(userProfileViewModel)
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
                }
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        if FirebaseApp.app() == nil {
            print("Firebase initialisation failed!")
        }
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["fcmToken": token], merge: true) { error in
            if let error = error {
                print("Error saving FCM token: \(error)")
            } else {
                print("FCM Token saved for user \(userId)")
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
}

