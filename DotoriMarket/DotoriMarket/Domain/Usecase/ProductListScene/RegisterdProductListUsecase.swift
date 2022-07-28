//
//  RegisterdProductListUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import Foundation

import RxSwift

struct RegisterdProductListUsecase: ProductListUsecase {
    
    let productRepository: ProductRepository
    private let registredProductRepository: RegisteredProductRepository
    
    init(productRepository: ProductRepository = MarketProductRepository(),
         registredProductRepository: RegisteredProductRepository = MarketRegisteredProductRepository()) {
        self.productRepository = productRepository
        self.registredProductRepository = registredProductRepository
    }
    
    private var registerdProducts = [Int]()
    private var registerdProductPages = [[Int]]()
    
    mutating func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
        if self.registerdProducts.isEmpty ||
            self.registerdProducts != self.registredProductRepository.fetchRegisteredProductIDs() {
            self.readProductIDs()
        }
        
        guard let pageToRequest = self.registerdProductPages[safe: pageNo - 1],
              let lastPage = self.registerdProductPages.last  else {
        return Observable.just(([ProductViewModel](), false))
        }
        
        let hasNext = (lastPage == pageToRequest) ? false :true
        
            return self.fetchProductViewModels(of: pageToRequest)
            .map{ ($0, hasNext) }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "등록 상품 관리",
                rightBarButtonImageSystemName: "plus.square.on.square"))
    }
    
    private mutating func readProductIDs() {
        self.registerdProducts = self.registredProductRepository.fetchRegisteredProductIDs()
        self.registerdProductPages = registerdProducts.chunked(into: 20)
    }
    
    private func fetchProductViewModels(of page: [Int]) -> Observable<[ProductViewModel]> {
        let requests = Observable.from(page)
            .flatMap({ id in
                self.productRepository.fetchProductDetail(of: id) })
     
        let productViewModels = requests
            .map{ detail in
                Product(id: detail.id, vendorID: detail.vendorID, name: detail.name, thumbnail: detail.thumbnail, currency: detail.currency, price: detail.price, bargainPrice: detail.bargainPrice, discountedPrice: detail.discountedPrice, stock: detail.stock) }
            .map{ ProductViewModel(product: $0) }
            .take(page.count)
            .reduce([]) { acc, element in return acc + [element] }
            .map { array in
                array.sorted { $0.id > $1.id }
            }
            
      return productViewModels
    }
    
}
