//
//  FavoriteProductsCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/21.
//

import UIKit

final class FavoriteProductsCoordinator: TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    var navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory.make(
            viewType: .favoriteProuducts,
            coordinator: self)
        self.navigationController.pushViewController(
            productListVC,
            animated: false)
    }
  
}

extension FavoriteProductsCoordinator: ProductListCoordinator {
    
    func rightNavigationItemDidTapped(from: UIViewController) {
        // no action needed
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
