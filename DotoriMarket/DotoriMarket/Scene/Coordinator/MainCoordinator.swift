//
//  MainCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
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
        let tabBars: [TabBar] = [.myProduct, .productList, .liked]
        self.childCoordinator = tabBars.map { $0.coordinator() }
        
        let tabViewControllers = tabBars.map { $0.navigationControllerWithTabBarItem()}
        
        tabBarController.setViewControllers(
            tabViewControllers,
            animated: false)
        tabBarController.selectedIndex = 1
        let designedVC = self.designTabBarController(tabBarController)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(designedVC, animated: false)
    }
    
    private func designTabBarController(_ vc: UITabBarController) -> UITabBarController {
        vc.tabBar.unselectedItemTintColor = DotoriColorPallete.identityColor
        vc.tabBar.tintColor = DotoriColorPallete.identityHighlightColor
        vc.tabBar.barTintColor = DotoriColorPallete.identityBackgroundColor
        
        return vc
    }
    
}
