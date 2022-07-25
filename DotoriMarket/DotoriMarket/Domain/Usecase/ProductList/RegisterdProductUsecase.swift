//
//  RegisterdProductUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/22.
//

import Foundation

import RxSwift

final class RegisterdProductUsecase: ProductListUsecase {
    
    var service: APIServcie =  MarketAPIService()
    private let productRegisterationRecorder = ProductRegisterationRecorder()
    
    private var registerdProducts = [Int]()
    private var registerdProductPages = [[Int]]()
    
    func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
        if self.registerdProducts.isEmpty ||
                self.registerdProducts != self.productRegisterationRecorder.readRegisterdProductIDs() {
            self.readProductIDs()
        }
        
        guard let pageToRequest = self.registerdProductPages[safe: pageNo - 1],
              let lastPage = self.registerdProductPages.last  else {
        return Observable.just(([ProductViewModel](), false))
        }
        
        let hasNext = (lastPage == pageToRequest) ? false :true
        
            return self.requestProductViewModels(of: pageToRequest)
            .map{ ($0, hasNext) }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "등록 상품 관리",
                rightBarButtonImageSystemName: "plus.square.on.square"))
    }
    
    private func readProductIDs() {
        self.registerdProducts = self.productRegisterationRecorder.readRegisterdProductIDs()
        self.registerdProductPages = registerdProducts.chunked(into: 20)
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
