//
//  AllProductListUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/20.
//

import Foundation
import RxSwift

class AllProductListUsecase: ProductListUsecase {

    var service =  MarketAPIService()
    
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
        let request = ProductsListPageRequest(pageNo: pageNo, itemsPerPage: itemsPerPage)
        return self.service.requestRx(request)
            .map{ response in response.toDomain()}
            .map{ listPage in
                let products = listPage.pages.map { product in
                    ProductViewModel(product: product)}
                return (products, listPage.hasNext)
            }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "상품 보기",
                rightBarButtonImageSystemName: "squareshape.split.2x2"))
    }
    
}
