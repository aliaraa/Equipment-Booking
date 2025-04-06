//
//  ProfileImageCache.swift
//  Equipment Booking
//
//  Created by Rene Mbanguka on 3/24/25.
//

import Foundation
import UIKit

class ProfileImageCache {
    static let shared = ProfileImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

