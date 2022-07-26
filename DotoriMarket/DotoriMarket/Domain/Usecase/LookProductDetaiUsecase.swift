//
//  LookProductDetaiUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import Foundation

import RxSwift

struct LookProductDetaiUsecase {
    
    private let productRepository: ProductRepository
    private let likeProductRecorder = LikeProductRecorder()
    
    init(productRepository: MarketProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func fetchPrdouctDetail(
        of productID: Int) -> Observable<(ProductDetailViewModel)> {
        self.productRepository.fetchProductDetail(of: productID)
            .map { detail in
                return ProductDetailViewModel(product: detail)
            }
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
