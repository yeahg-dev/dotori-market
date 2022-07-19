//
//  ProductListCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import UIKit

class ProductListCoordinator: Coordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productListViewController = storyboard.instantiateViewController(
            withIdentifier: "ProductCollectionViewController") as? ProductCollectionViewController else {
            return
        }
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.setViewControllers(
            [productListViewController],
            animated: false)
    }
    
}

extension ProductListCoordinator: TabCoordinator {
    
    func tabViewController() -> UINavigationController {
        self.start()
        return self.navigationController
    }
    
}
