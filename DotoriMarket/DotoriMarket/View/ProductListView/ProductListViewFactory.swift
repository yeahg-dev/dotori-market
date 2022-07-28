//
//  ProductListViewFactory.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/20.
//

import UIKit

struct ProductListViewFactory {
    
    // MARK: - ProductListView Type
    
    enum ProductListView {
        case allProduct
        case favoriteProuduct
        case myProduct
    }
    
    func make(
        viewType: ProductListView,
        coordinator: ProductListCoordinator) -> ProductTableViewController {
        switch viewType {
        case .allProduct:
            return UIStoryboard.main.instantiateViewController(
                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
                    let viewModel = ProductListSceneViewModel(usecase: AllProductListUsecase())
                    let vc = ProductTableViewController(
                        viewModel: viewModel,
                        coordinator: coordinator,
                        coder: coder)
                    return vc!
                })
        case .favoriteProuduct:
            return UIStoryboard.main.instantiateViewController(
                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
                    let viewModel = ProductListSceneViewModel(usecase: FavoriteProductListUsecase())
                    let vc = ProductTableViewController(
                        viewModel: viewModel,
                        coordinator: coordinator,
                        coder: coder)
                    return vc!
                })
        case .myProduct:
            return UIStoryboard.main.instantiateViewController(
                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
                    let viewModel = ProductListSceneViewModel(usecase: RegisterdProductListUsecase())
                    let vc = ProductTableViewController(
                        viewModel: viewModel,
                        coordinator: coordinator,
                        coder: coder)
                    return vc!
                })
        }
    }

}
