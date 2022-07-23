//
//  ALLProductListCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import UIKit

protocol ProductListCoordinator: Coordinator {
    
    func rightNavigationItemDidTapped(from: UIViewController)
    func cellDidTapped(of productID: Int) 
    
}

class AllProductListCoordinator: ProductListCoordinator, TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductCollectionViewController.make(coordinator: self)
        self.desingNavigationController()
        self.navigationController.pushViewController(productListVC,
                                                     animated: false)
    }
    
    func cellDidTapped(of productID: Int) {
        let productDetailVC = UIStoryboard.initiateViewController(ProductDetailViewController.self)
        productDetailVC.setProduct(productID)
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(productDetailVC,
                                                     animated: true)
    }
    
    func rightNavigationItemDidTapped(from vc: UIViewController) {
        if vc.className == ProductCollectionViewController.className {
            let productListVC = ProductListViewFactory().make(
                viewType: .allProduct,
                coordinator: self)
            self.navigationController.setViewControllers([productListVC],
                                                         animated: false)
        } else {
            let productListVC = ProductCollectionViewController.make(coordinator: self)
            self.navigationController.setViewControllers([productListVC],
                                                         animated: false)
        }
    }
    
    private func desingNavigationController() {
        self.navigationController.navigationBar.tintColor = DotoriColorPallete.identityColor
    }
    
}
