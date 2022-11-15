//
//  TabBarChilds.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/18.
//

import UIKit

enum TabBarChilds {
    
    case allProducts
    case registeredProducts
    case favoriteProducts
    
    var coordinator: TabCoordinator {
        switch self {
        case .allProducts:
            return AllProductsCoordinator()
        case .registeredProducts:
            return RegisteredProductsCoordinator()
        case .favoriteProducts:
            return FavoriteProductsCoordinator()
        }
    }
    
    var navigationControllerWithTabBarItem: UINavigationController {
        switch self {
        case .allProducts:
            let tabBarItem = AllProductsTabBarItem().tabBarItem
            let navigationVC = self.coordinator.tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .registeredProducts:
            let tabBarItem = RegisteredProductsTabBarItem().tabBarItem
            let navigationVC = self.coordinator.tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        case .favoriteProducts:
            let tabBarItem = FavoriteProductsTabBarItem().tabBarItem
            let navigationVC = self.coordinator.tabViewController()
            navigationVC.tabBarItem = tabBarItem
            return navigationVC
        }
    }

}
