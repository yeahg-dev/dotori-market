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
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
            self.productRepository.fetchProductListPage(
                of: pageNo,
                itemsPerPage: itemsPerPage)
            .map { listPage -> ([ProductViewModel], Bool)in
                let products = listPage.pages.map{ ProductViewModel(product: $0)}
                return (products, listPage.hasNext)
            }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "상품 보기",
                rightBarButtonImageSystemName: "square.grid.2x2.fill"))
    }
    
}
