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
        case likedProuduct
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
        case .likedProuduct:
            return UIStoryboard.main.instantiateViewController(
                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
                    let viewModel = ProductListSceneViewModel(usecase: LlikeProductListUsecase())
                    let vc = ProductTableViewController(
                        viewModel: viewModel,
                        coordinator: coordinator,
                        coder: coder)
                    return vc!
                })
        case .myProduct:
            return UIStoryboard.main.instantiateViewController(
                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
                    let viewModel = ProductListSceneViewModel(usecase: RegisterdProductUsecase())
                    let vc = ProductTableViewController(
                        viewModel: viewModel,
                        coordinator: coordinator,
                        coder: coder)
                    return vc!
                })
        }
    }

}
