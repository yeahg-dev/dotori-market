//
//  ProductListSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/18.
//

import Foundation

import RxSwift

final class ProductListSceneViewModel {
    
    private let APIService = MarketAPIService()
    private var productsViewModels: [ProductViewModel] = []
    private let paginationBuffer = 3
    private var currentPage: Int = 0
    private let itemsPerPage = 20
    private var hasNextPage: Bool = false
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let willDisplayCellAtIndex: Observable<Int>
        let listViewDidStartRefresh: Observable<Void>
        let cellDidSelectedAt: Observable<Int>
    }
    
    struct Output {
        let willStartLoadingIndicator: Observable<Void>
        let willEndLoadingIndicator: Observable<Void>
        let products: Observable<[ProductViewModel]>
        let listViewWillEndRefresh: Observable<Void>
        let pushProductDetailView: Observable<Int>
    }
    
    func transform(input: Input) -> Output {
        let willStartLoadingIndicator = PublishSubject<Void>()
        let willEndLoadingIndicator = PublishSubject<Void>()
        
        let viewWillAppear = input.viewWillAppear
            .do(onNext: { self.resetPage()
                willStartLoadingIndicator.onNext(()) })
                
        let pagination = input.willDisplayCellAtIndex
            .filter{ currentRow in
                (currentRow == self.productsViewModels.count - self.paginationBuffer) &&  self.hasNextPage }
            .map{ _ in }
            .do(onNext: { willStartLoadingIndicator.onNext(()) })
        
        let listViewDidStartRefresh = input.listViewDidStartRefresh
            .do(onNext: { self.resetPage() })
            
        let products = Observable.merge(viewWillAppear, pagination, listViewDidStartRefresh)
            .flatMap{ _ -> Observable<ProductsListPageResponse> in
                let request = ProductsListPageRequest(pageNo: self.currentPage + 1, itemsPerPage: 20)
                return self.APIService.requestRx(request) }
            .map{ response in response.toDomain() }
            .do(onNext: { listPage in
                self.currentPage += 1
                self.hasNextPage = listPage.hasNext })
            .map{ (listPage: ProductListPage) -> [ProductViewModel] in
                let products = listPage.pages.map { product in
                    ProductViewModel(product: product)}
                self.productsViewModels.append(contentsOf: products)
                return self.productsViewModels }
            .do(onNext: { _ in willEndLoadingIndicator.onNext(()) })
            .share(replay: 1)
        
        let endRefresh = products.map { _ in }
        
        let pushProductDetailView = input.cellDidSelectedAt
            .map{ index -> Int in
                guard let product = self.productsViewModels[safe: index] else { return .zero }
                return product.id }
            .do(onNext: { _ in self.resetPage() })
                
        return Output(willStartLoadingIndicator: willStartLoadingIndicator.asObservable(),
                      willEndLoadingIndicator: willEndLoadingIndicator.asObservable(),
                      products: products,
                      listViewWillEndRefresh: endRefresh,
                      pushProductDetailView: pushProductDetailView)
                }
    
    private func resetPage() {
        self.currentPage = 0
        self.productsViewModels = []
    }
}

