//
//  ImageCacheManager.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/18.
//

import UIKit

class ImageCacheManager {
    
    static let shared = NSCache<NSString, UIImage>()
    
    private init() { }
}
