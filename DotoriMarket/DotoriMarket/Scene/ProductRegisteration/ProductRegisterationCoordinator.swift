//
//  ProductRegisterationCoordinator.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/23.
//

import UIKit

final class ProductRegisterationCoordinator: Coordinator {
    
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let registerationVC = UIStoryboard.main.instantiateViewController(
            identifier: "ProductRegistrationViewController", creator:  { coder -> ProductRegistrationViewController in
                let viewModel = ProductRegisterationSceneViewModel(usecase: ProductRegisterationUsecase())
                let vc = ProductRegistrationViewController(
                    viewModel: viewModel,
                    coordinator: self,
                    coder: coder)
                return vc!
            })
        registerationVC.modalPresentationStyle = .fullScreen

        self.navigationController.present(registerationVC, animated: true)
    }
    
    func transitionToAllProduct() {
        self.navigationController.tabBarController?.selectedIndex = 1
    }
    
}
