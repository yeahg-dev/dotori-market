//
//  MainCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/18.
//

import UIKit

class MainCoordinator: Coordinator {
    
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
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(tabBarController, animated: false)
    }
    
}
