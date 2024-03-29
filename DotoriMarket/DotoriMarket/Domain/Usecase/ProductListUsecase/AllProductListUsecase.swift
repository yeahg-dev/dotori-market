//
//  AllProductListUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/20.
//

import Foundation

import RxSwift

class AllProductListUsecase: ProductListUsecase {

    var productRepository: ProductRepository
    
    init(productRepository: ProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int,
        searchValue: String? = nil)
    -> Observable<([ProductViewModel], Bool)>
    {
            self.productRepository.fetchProductListPage(
                of: pageNo,
                itemsPerPage: itemsPerPage,
                searchValue: searchValue)
            .map { listPage -> ([ProductViewModel], Bool)in
                let products = listPage.pages.map{ ProductViewModel(product: $0)}
                return (products, listPage.hasNext)
            }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponentViewModel> {
        return Observable.just(
            NavigationBarComponentViewModel(
                title: "상품 보기",
                rightBarButtonImageSystemName: "square.grid.2x2.fill"))
    }
    
}
