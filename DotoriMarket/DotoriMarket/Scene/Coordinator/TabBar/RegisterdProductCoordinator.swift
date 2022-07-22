//
//  RegisterdProductCoordinator.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/22.
//

import Foundation

import UIKit

class RegisterdProductCoordinator: ProductListCoordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init () {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let productListVC = ProductListViewFactory().make(
            viewType: .myProduct,
            coordinator: self)
        self.navigationController.pushViewController(productListVC,
                                                     animated: false)
    }
    
    func pushProuductDetail(of productID: Int) {
        
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
        let productRegisterationVC =  UIStoryboard.initiateViewController(ProductRegistrationViewController.self)
        productRegisterationVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(productRegisterationVC, animated: true)
    }

}

extension RegisterdProductCoordinator: TabCoordinator {
    
    func tabViewController() -> UINavigationController {
        self.start()
        return self.navigationController
    }
    
}
