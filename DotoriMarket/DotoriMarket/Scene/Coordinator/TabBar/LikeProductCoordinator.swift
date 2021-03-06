//
//  FavoriteProductListCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/21.
//


import UIKit

final class FavoriteProductListCoordinator: ProductListCoordinator, TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory().make(
            viewType: .favoriteProuduct,
            coordinator: self)
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
    
    func rightNavigationItemDidTapped(from: UIViewController) {
        // no action needed
    }

}
