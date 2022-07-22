//
//  TabBar.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

enum TabBar {
    
    case productList
    case myProduct
    case liked
    
    func coordinator() -> TabCoordinator {
        switch self {
        case .productList:
            return AllProductListCoordinator()
        case .myProduct:
            return RegisterdProductCoordinator()
        case .liked:
            return LikeProductListCoordinator()
        }
    }
    
    func navigationControllerWithTabBarItem() -> UINavigationController {
        switch self {
        case .productList:
            let tabBarItem = ProductListTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .myProduct:
            let tabBarItem = MyProductTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .liked:
            let tabBarItem = LikedTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        }
    }

}
