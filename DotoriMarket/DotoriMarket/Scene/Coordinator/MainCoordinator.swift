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
        let tabBars: [TabBar] = [.myDotori, .productList, .liked]
        let tabControllers = tabBars.map { $0.components() }
            .map { $0.tabViewController() }
        tabBarController.setViewControllers(tabControllers, animated: false)
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(tabBarController, animated: false)
    }
    
}
