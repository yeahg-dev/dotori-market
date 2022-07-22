//
//  LikeProductCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//


import UIKit

class LikeProductListCoordinator: ProductListCoordinator, TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory().make(
            viewType: .likedProuduct,
            coordinator: self)
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
    
    func rightNavigationItemDidTapped(from: UIViewController) {
        // no action needed
    }

}
