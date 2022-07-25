//
//  ImageCacheStorage.swift
//  DotoriMarket
//
//  Created by 예거 on 2022/01/18.
//

import UIKit

final class ImageCacheStorage {
    
    static let shared = NSCache<NSString, UIImage>()
    
    func cache(_ image: UIImage, of cacheKey: String) {
        ImageCacheStorage.shared.setObject(image, forKey: cacheKey as NSString)
    }
    
    func getImage(of cacheKey: String) -> UIImage? {
        return ImageCacheStorage.shared.object(forKey: cacheKey as NSString)
    }
    
}
