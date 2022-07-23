//
//  LlikeProductListUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/21.
//

import Foundation

import RxSwift

class LlikeProductListUsecase: ProductListUsecase {

    var service: APIServcie =  MarketAPIService()
    private let likeProductRecorder = LikeProductRecorder()
    
    private var likeProducts = [Int]()
    private var likeProductPages = [[Int]]()
    
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
        if self.likeProducts.isEmpty ||
                self.likeProducts != self.likeProductRecorder.readlikeProductIDs() {
            self.readLikeProductIDs()
        }
        
        guard let pageToRequest = self.likeProductPages[safe: pageNo - 1],
              let lastPage = self.likeProductPages.last  else {
        return Observable.just(([ProductViewModel](), false))
        }
        
        let hasNext = (lastPage == pageToRequest) ? false :true
        
            return self.requestProductViewModels(of: pageToRequest)
            .map{ ($0, hasNext) }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "좋아요한 상품",
                rightBarButtonImageSystemName: ""))
    }
    
    
    private func readLikeProductIDs() {
        self.likeProducts = self.likeProductRecorder.readlikeProductIDs()
        self.likeProductPages = likeProducts.chunked(into: 20)
    }
    
    private func requestProductViewModels(of page: [Int]) -> Observable<[ProductViewModel]> {
        let requests = Observable.from(page)
            .map{ ProductDetailRequest(productID: $0) }
            .flatMap{ request in
                self.service.requestRx(request)}
            .map{ $0.toDomain() }
     
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
