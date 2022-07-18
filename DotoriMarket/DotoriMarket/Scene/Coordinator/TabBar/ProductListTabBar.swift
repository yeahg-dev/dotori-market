//
//  ProductListTabBar.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/19.
//

import UIKit

class ProductListTabBar {
    
    private var viewController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productListViewController = storyboard.instantiateViewController(
            withIdentifier: "ProductCollectionViewController") as? ProductCollectionViewController else {
            return UINavigationController()
        }
        navigationController.setViewControllers(
            [productListViewController],
            animated: false)
        return navigationController
    }()
    
    private lazy var tabBarItem: UITabBarItem  = {
        let list = UITabBarItem(title: "모아보기",
                                image: image,
                                selectedImage: selectedImage)
        return list
    }()
    
    private var image: UIImage? = {
        let image = UIImage(systemName: "square.grid.2x2")
        return image
    }()
    
    private var selectedImage: UIImage? = {
        let image = UIImage(systemName: "square.grid.2x2.fill")
        return image
    }()
    
}

// MARK: - TabBarComponent

extension ProductListTabBar: TabBarComponent {

    func tabViewController() -> UINavigationController {
        self.viewController.tabBarItem = self.tabBarItem
        return self.viewController
    }

}
