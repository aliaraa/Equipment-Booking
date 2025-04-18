//
//  Utilities.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 12/28/24.
//

import Foundation
import UIKit


// Get top view controller for use in google sign in
final class Utilities {
    static let shared = Utilities()
    private init() {}
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        // If a controller is passed, use it; otherwise, find the root from the current scene
        var rootController: UIViewController?
        if controller == nil {
            // Access the first connected scene's foreground-active window
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                rootController = windowScene.windows
                    .first(where: { $0.isKeyWindow })?.rootViewController
            }
            // Fallback to any window if no foreground-active scene is found
            if rootController == nil {
                rootController = UIApplication.shared.windows
                    .first(where: { $0.isKeyWindow })?.rootViewController
            }
        } else {
            rootController = controller
        }
        
        // Traverse the view controller hierarchy
        if let navigationController = rootController as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = rootController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = rootController?.presentedViewController {
            return topViewController(controller: presented)
        }
        return rootController
    }
}

//final class Utilities {
//    static let shared = Utilities()
//    private init() {}
//    
//    @MainActor
//    // Struct to add a clear button to textfields
//
//  
//    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
//        
//        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
////        let controller = UIApplication.topViewController(controller: controller)
//        
//        if let navigationController = controller as? UINavigationController {
//            return topViewController(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topViewController(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return topViewController(controller: presented)
//        }
//        return controller
//    }
//    
//}

