//
//  RegisteredProductsCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import UIKit

final class RegisteredProductsCoordinator: TabCoordinator {
    
    var childCoordinator = [Coordinator]()
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory.make(
            viewType: .registeredProducts,
            coordinator: self)
        self.desingNavigationController()
        self.navigationController.pushViewController(
            productListVC,
            animated: false)
    }
    
    private func desingNavigationController() {
        self.navigationController.navigationBar.tintColor = DotoriColorPallete.identityColor
    }
    
}

extension RegisteredProductsCoordinator: ProductListCoordinator {
    
    func rightNavigationItemDidTapped(from: UIViewController) {
        let productRegisterationCoordinator = ProductRegistrationCoordinator(
            navigationController: self.navigationController)
        childCoordinator.append(productRegisterationCoordinator)
        productRegisterationCoordinator.start()
    }
    
    func cellDidTapped(of productID: Int) {
        guard let productEditVC = UIStoryboard.main.instantiateViewController(
            withIdentifier: "ProductEditViewController") as? ProductEditViewController else {
            return
        }
        productEditVC.setProduct(productID)
        productEditVC.modalPresentationStyle = .fullScreen

        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(
            productEditVC,
            animated: true)
    }

}
