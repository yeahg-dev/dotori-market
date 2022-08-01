//
//  TabBar.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/18.
//

import UIKit

enum TabBar {
    
    case productList
    case myProduct
    case favoriteProducts
    
    func coordinator() -> TabCoordinator {
        switch self {
        case .productList:
            return AllProductListCoordinator()
        case .myProduct:
            return MyProductCoordinator()
        case .favoriteProducts:
            return FavoriteProductListCoordinator()
        }
    }
    
    func navigationControllerWithTabBarItem() -> UINavigationController {
        switch self {
        case .productList:
            let tabBarItem = AllProductTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .myProduct:
            let tabBarItem = MyProductTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .favoriteProducts:
            let tabBarItem = FavoriteProductTabBarItem().tabBarItem
            let navigationVC = self.coordinator().tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        }
    }

}
