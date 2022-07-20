//
//  ProductListSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/18.
//

import Foundation

import RxSwift
import RxCocoa

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
        let navigationBarComponent: Driver<NavigationBarComponent>
        let willStartLoadingIndicator: Driver<Void>
        let willEndLoadingIndicator: Driver<Void>
        let products: Driver<[ProductViewModel]>
        let listViewWillEndRefresh: Driver<Void>
        let pushProductDetailView: Driver<Int>
        let networkErrorAlert: Driver<AlertViewModel>
    }
    
    func transform(input: Input) -> Output {
        let willStartLoadingIndicator = PublishSubject<Void>()
        let willEndLoadingIndicator = PublishSubject<Void>()
        
        let navigationBarComponent = Driver.just(
            NavigationBarComponent(
                title: "상품 보기",
                rightBarButtonImageSystemName: "squareshape.split.2x2"))
        
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
        
        let networkErrorAlert = PublishSubject<AlertViewModel>()
                
        let products = Observable.merge(viewWillAppear, pagination, listViewDidStartRefresh)
            .flatMap{ _ -> Observable<ProductsListPageResponse> in
                let request = ProductsListPageRequest(pageNo: self.currentPage + 1, itemsPerPage: 20)
                return self.APIService.requestRx(request) }
            .do(onError: { _ in
                networkErrorAlert.onNext(NetworkErrorAlertViewModel() as AlertViewModel)
            } )
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
            .asDriver(onErrorJustReturn: [])
        
        let endRefresh = products.map { _ in }.asDriver(onErrorJustReturn: ())
        
        let pushProductDetailView = input.cellDidSelectedAt
            .map{ index -> Int in
                guard let product = self.productsViewModels[safe: index] else { return .zero }
                return product.id }
            .do(onNext: { _ in self.resetPage() })
            .asDriver(onErrorJustReturn: 0)
        
        return Output(navigationBarComponent: navigationBarComponent,
                      willStartLoadingIndicator: willStartLoadingIndicator.asDriver(onErrorJustReturn: ()),
                      willEndLoadingIndicator: willEndLoadingIndicator.asDriver(onErrorJustReturn: ()),
                      products: products,
                      listViewWillEndRefresh: endRefresh,
                      pushProductDetailView: pushProductDetailView,
                      networkErrorAlert: networkErrorAlert.asDriver(onErrorJustReturn: NetworkErrorAlertViewModel() as AlertViewModel))
                }
    
    private func resetPage() {
        self.currentPage = 0
        self.productsViewModels = []
    }
}
