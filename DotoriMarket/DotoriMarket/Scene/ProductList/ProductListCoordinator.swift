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
        let productListVC = ProductCollectionViewController.make(coordinator: self)
        self.navigationController.pushViewController(productListVC,
                                                     animated: false)
    }
    
    func pushProuductDetail(of productID: Int) {
        let productDetailVC = UIStoryboard.initiateViewController(ProductDetailViewController.self)
        productDetailVC.setProduct(productID)
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(productDetailVC,
                                                     animated: true)
    }
    
    func toggleViewMode(from vc: UIViewController) {
        if vc.className == ProductCollectionViewController.className {
            let productListVC = ProductTableViewController.make(coordinator: self)
            self.navigationController.setViewControllers([productListVC],
                                                         animated: false)
        } else {
            let productListVC = ProductCollectionViewController.make(coordinator: self)
            self.navigationController.setViewControllers([productListVC],
                                                         animated: false)
        }
    }
    
    func childDidFinish(_ child: Coordinator?){
        guard let child = child else {
            return
        }

        for (index, coordinator) in self.childCoordinator.enumerated() {
            if coordinator === child {
                self.childCoordinator.remove(at: index)
                break
            }
        }
    }
    
}

extension ProductListCoordinator: TabCoordinator {
    
    func tabViewController() -> UINavigationController {
        self.start()
        return self.navigationController
    }
    
}
