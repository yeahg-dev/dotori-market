//
//  ProductTableViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/18.
//

import Foundation
import RxSwift

class ProductTableViewModel {
    
    private let APIService = MarketAPIService()
    private var productsViewModels: [ProductViewModel] = []
    private var currentPage: Int = 0
    private let itemsPerPage = 20
    private var hasNextPage: Bool = false
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let products: Observable<[ProductViewModel]>
        
    }
    
    func transform(input: Input) -> Output {
        let products = input.viewWillAppear
            .flatMap { _ -> Observable<ProductsListPage> in
                let request = ProductsListPageRequest(pageNo: self.currentPage + 1, itemsPerPage: 20)
                return self.APIService.requestRx(request) }
            .do(onNext: {listPage in
                self.currentPage += 1
                self.hasNextPage = listPage.hasNext
            })
            .map { listPage -> [ProductViewModel] in
                let products = listPage.pages.map { product in
                    ProductViewModel(product: product)}
                self.productsViewModels.append(contentsOf: products)
                return self.productsViewModels }
                
       return Output(products: products)
    }
}
