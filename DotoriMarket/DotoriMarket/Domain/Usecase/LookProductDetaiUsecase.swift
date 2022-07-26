//
//  LookProductDetaiUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import Foundation

import RxSwift

struct LookProductDetaiUsecase {
    
    private let service: MarketAPIService
    private let likeProductRecorder = LikeProductRecorder()
    
    init(service: MarketAPIService = MarketAPIService()) {
        self.service = service
    }
    
    func fetchPrdouctDetail(
        of productID: Int) -> Observable<(ProductDetailViewModel)> {
         let request = ProductDetailRequest(productID: productID)
            
        return self.service.requestRx(request)
            .map{ $0.toDomain() }
            .map{ ProductDetailViewModel(product: $0) }
        }
    
    func readIsLikeProduct(of productID: Int) -> Bool {
        return self.likeProductRecorder.readIsLike(productID: productID)
    }
    
    func recordLikeProduct(of productID: Int) {
        likeProductRecorder.recordLikeProduct(productID: productID)
    }
    
    func recordUnlikeProduct(of productID: Int) {
        likeProductRecorder.recordUnlikeProduct(productID: productID)
    }
    
}
