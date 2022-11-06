//
//  ProductListSceneViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/18.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductListSceneViewModel {
    
    private var productListUsecase: ProductListUsecase
    
    private var productsViewModels: [ProductViewModel] = []
    private let paginationBuffer = 3
    private var currentPage: Int = 0
    private let itemsPerPage = 20
    private var hasNextPage: Bool = false
    
    init(usecase: ProductListUsecase) {
        self.productListUsecase = usecase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let willDisplayCellAtIndex: Observable<IndexPath>
        let listViewDidStartRefresh: Observable<Void>
        let cellDidSelectedAt: Observable<IndexPath>
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
        
        let navigationBarComponent = self.productListUsecase
            .fetchNavigationBarComponent()
            .asDriver(onErrorJustReturn: NavigationBarComponent(
                title: "보기",
                rightBarButtonImageSystemName: "squareshape.split.2x2"))
        
        let viewWillAppear = input.viewWillAppear
            .do(onNext: { self.resetPage()
                willStartLoadingIndicator.onNext(()) })
                
        let willLoadNextPage = input.willDisplayCellAtIndex
            .map{ $0.row }
            .filter{ currentRow in
                (currentRow == self.productsViewModels.count - self.paginationBuffer) && self.hasNextPage }
            .map{ _ in }
            .do(onNext: { willStartLoadingIndicator.onNext(()) })
        
        let listViewDidStartRefresh = input.listViewDidStartRefresh
            .do(onNext: { self.resetPage() })
        
        let networkErrorAlert = PublishSubject<AlertViewModel>()
                
        let products = Observable.merge(
            viewWillAppear, willLoadNextPage, listViewDidStartRefresh)
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .default))
            .flatMap{ _ -> Observable<([ProductViewModel], Bool)> in
                self.productListUsecase.fetchPrdoucts(
                    pageNo: self.currentPage + 1,
                    itemsPerPage: 20,
                    searchValue: nil) }
            .do(onError: { _ in
                networkErrorAlert.onNext(NetworkErrorAlertViewModel() as AlertViewModel)
                willEndLoadingIndicator.onNext(()) })
            .retry(when: { _ in listViewDidStartRefresh })
            .do(onNext: { (viewModels, hasNextPage) in
                self.currentPage += 1
                self.hasNextPage = hasNextPage
                self.productsViewModels.append(contentsOf: viewModels)
                willEndLoadingIndicator.onNext(()) })
            .map{ _ in self.productsViewModels}
            .asDriver(onErrorJustReturn: Array<ProductViewModel>())
        
        let endRefresh = products.map { _ in }
            .asDriver(onErrorJustReturn: ())
        
        let pushProductDetailView = input.cellDidSelectedAt
            .map{ $0.row }
            .map{ index -> Int in
                guard let product = self.productsViewModels[safe: index] else { return .zero }
                return product.id }
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
