//
//  AllProductsCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/19.
//

import UIKit

final class AllProductsCoordinator: TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    var navigationController: UINavigationController
    lazy var productCollectionViewContorller = ProductCollectionViewController.make(coordinator: self)
    lazy var productTableViewController = ProductListViewFactory().make(
        viewType: .allProduct,
        coordinator: self)
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        self.desingNavigationController()
        self.navigationController.pushViewController(
            productCollectionViewContorller,
            animated: false)
    }
    
    private func desingNavigationController() {
        self.navigationController.navigationBar.tintColor = DotoriColorPallete.identityColor
    }
    
}

extension AllProductsCoordinator: ProductListCoordinator {
    
    func rightNavigationItemDidTapped(from vc: UIViewController) {
        if vc.className == ProductCollectionViewController.className {
            self.navigationController.setViewControllers(
                [productTableViewController],
                animated: false)
        } else {
            self.navigationController.setViewControllers(
                [productCollectionViewContorller],
                animated: false)
        }
    }
    
    func cellDidTapped(of productID: Int) {
        let productDetailVC = UIStoryboard.initiateViewController(ProductDetailViewController.self)
        productDetailVC.setProduct(productID)
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(
            productDetailVC,
            animated: true)
    }
    
}
