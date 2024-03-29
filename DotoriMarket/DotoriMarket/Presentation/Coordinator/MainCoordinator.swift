//
//  MainCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/18.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    var childCoordinator = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = UITabBarController()
        let tabBarChilds: [TabBarChilds] = [.registeredProducts, .allProducts, .favoriteProducts]
        self.childCoordinator = tabBarChilds.map { $0.coordinator }
        
        let childViewControllers = tabBarChilds.map { $0.navigationControllerWithTabBarItem}
        
        tabBarController.setViewControllers(
            childViewControllers,
            animated: false)
        tabBarController.selectedIndex = 1
        let designedVC = self.designTabBarController(tabBarController)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(designedVC, animated: false)
    }
    
    private func designTabBarController(
        _ vc: UITabBarController)
    -> UITabBarController
    {
        vc.tabBar.unselectedItemTintColor = DotoriColorPallete.identityColor
        vc.tabBar.tintColor = DotoriColorPallete.identityHighlightColor
        vc.tabBar.barTintColor = DotoriColorPallete.identityBackgroundColor
        
        return vc
    }
    
}
