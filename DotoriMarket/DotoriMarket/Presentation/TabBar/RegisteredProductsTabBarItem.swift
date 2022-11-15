//
//  RegisteredProductsTabBarItem.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/19.
//

import UIKit

final class RegisteredProductsTabBarItem {
  
    lazy var tabBarItem: UITabBarItem  = {
        let list = UITabBarItem(title: "내 상품",
                                image: image,
                                selectedImage: selectedImage)
        return list
    }()
    
    private var image: UIImage? = {
        let image = UIImage(systemName: "m.square")
        return image
    }()
    
    private var selectedImage: UIImage? = {
        let image = UIImage(systemName: "m.square.fill")
        return image
    }()
    
}
