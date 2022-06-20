//
//  ProductTableViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/18.
//

import Foundation
import RxSwift

final class ProductListViewModel {
    
    private let APIService = MarketAPIService()
    private var productsViewModels: [ProductViewModel] = []
    private let paginationBuffer = 3
    private var currentPage: Int = 0
    private let itemsPerPage = 20
    private var hasNextPage: Bool = false
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let willDisplayCell: Observable<Int>
        let willRefrsesh: Observable<Void>
        let didSelectRowAt: Observable<Int>
    }
    
    struct Output {
        let products: Observable<[ProductViewModel]>
        let endRefresh: Observable<Void>
        let pushProductDetailView: Observable<Int>
    }
    
    func transform(input: Input) -> Output {
        let viewWillAppear = input.viewWillAppear
            .do(onNext: { _ in
                self.resetPage()})
                
        let pagination = input.willDisplayCell
            .filter { currentRow in
                currentRow == self.productsViewModels.count - self.paginationBuffer }
            .filter { _ in self.hasNextPage == true }
            .map {_ in }
        
        let willRefreshPage = input.willRefrsesh
            .do { _ in
                self.resetPage() }
            
        let products = Observable.of(viewWillAppear, pagination, willRefreshPage)
            .merge()
            .flatMap { _ -> Observable<ProductsListPage> in
                let request = ProductsListPageRequest(pageNo: self.currentPage + 1, itemsPerPage: 20)
                return self.APIService.requestRx(request) }
            .do(onNext: {listPage in
                self.currentPage += 1
                self.hasNextPage = listPage.hasNext
            })
            .map { (listPage: ProductsListPage) -> [ProductViewModel] in
                let products = listPage.pages.map { product in
                    ProductViewModel(product: product)}
                self.productsViewModels.append(contentsOf: products)
                return self.productsViewModels }
            .share(replay: 1)
        
        let endRefresh = products.map { _ in }
        
        let pushProductDetailView = input.didSelectRowAt
            .map { index -> Int in
                guard let product = self.productsViewModels[safe: index] else {
                    return .zero
                }
                return product.id }
            .do(onNext: { _ in
                self.resetPage() })
                
       return Output(products: products,
                     endRefresh: endRefresh,
                     pushProductDetailView: pushProductDetailView)
    }
    
    private func resetPage() {
        self.currentPage = 0
        self.productsViewModels = []
    }
}

enum ProductTableViewModelError: Error {
    
    case invalidProduct
}
