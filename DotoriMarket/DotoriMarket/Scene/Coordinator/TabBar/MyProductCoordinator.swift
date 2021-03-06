//
//  MyProductCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import UIKit

final class MyProductCoordinator: ProductListCoordinator, TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory().make(
            viewType: .myProduct,
            coordinator: self)
        self.desingNavigationController()
        self.navigationController.pushViewController(productListVC,
                                                     animated: false)
    }
    
    func cellDidTapped(of productID: Int) {
        guard let productEditVC = UIStoryboard.main.instantiateViewController(
            withIdentifier: "ProductEditViewController") as? ProductEditViewController else {
            return
        }
        productEditVC.setProduct(productID)
        productEditVC.modalPresentationStyle = .fullScreen

        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(productEditVC,
                                                     animated: true)
    }
    
    func rightNavigationItemDidTapped(from: UIViewController) {
        let productRegisterationCoordinator = ProductRegistrationCoordinator(
            navigationController: self.navigationController)
        childCoordinator.append(productRegisterationCoordinator)
        productRegisterationCoordinator.start()
    }

    private func desingNavigationController() {
        self.navigationController.navigationBar.tintColor = DotoriColorPallete.identityColor
    }
    
}
