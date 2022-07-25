//
//  LikeProductTabBarItem.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import UIKit

final class LikeProductTabBarItem {
  
    lazy var tabBarItem: UITabBarItem  = {
        let list = UITabBarItem(title: "좋아요",
                                image: image,
                                selectedImage: selectedImage)
        return list
    }()
    
    private var image: UIImage? = {
        let image = UIImage(systemName: "heart")
        return image
    }()
    
    private var selectedImage: UIImage? = {
        let image = UIImage(systemName: "heart.fill")
        return image
    }()
    
}
