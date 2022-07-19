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
        self.navigationController.setNavigationBarHidden(true, animated: false)
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
    
}

extension ProductListCoordinator: TabCoordinator {
    
    func tabViewController() -> UINavigationController {
        self.start()
        return self.navigationController
    }
    
}
