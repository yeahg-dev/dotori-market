//
//  ProductRegistrationCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/23.
//

import UIKit

final class ProductRegistrationCoordinator: Coordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let registrationVC = UIStoryboard.main.instantiateViewController(
            identifier: "ProductRegistrationViewController", creator:  { coder -> ProductRegistrationViewController in
                let viewModel = ProductRegistrationSceneViewModel(usecase: ProductRegistrationUsecase())
                let vc = ProductRegistrationViewController(
                    viewModel: viewModel,
                    coordinator: self,
                    coder: coder)
                return vc!
            })
        registrationVC.modalPresentationStyle = .fullScreen

        self.navigationController.present(registrationVC, animated: true)
    }
    
    func transitionToAllProduct() {
        self.navigationController.tabBarController?.selectedIndex = 1
    }
    
}
