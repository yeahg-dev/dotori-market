//
//  ProductListTabBarItem.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/19.
//

import UIKit

final class AllProductTabBarItem {
  
    lazy var tabBarItem: UITabBarItem  = {
        let list = UITabBarItem(title: "모아보기",
                                image: image,
                                selectedImage: selectedImage)
        return list
    }()
    
    private var image: UIImage? = {
        let image = UIImage(systemName: "square.grid.2x2")
        return image
    }()
    
    private var selectedImage: UIImage? = {
        let image = UIImage(systemName: "square.grid.2x2.fill")
        return image
    }()
    
}
