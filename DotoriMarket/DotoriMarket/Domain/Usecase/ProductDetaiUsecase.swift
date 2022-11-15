//
//  ProductDetaiUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/22.
//

import Foundation

import RxSwift

struct ProductDetaiUsecase {
    
    private let productRepository: ProductRepository
    private let favoriteProductRepository: FavoriteProductRepository
    
    init(
        productRepository: MarketProductRepository = MarketProductRepository(),
        favoriteProductRepository: FavoriteProductRepository = MarketFavoriteProductRepository()) {
        self.productRepository = productRepository
        self.favoriteProductRepository = favoriteProductRepository
    }
    
    func fetchPrdouctDetail(
        of productID: Int)
    -> Observable<(ProductDetailViewModel)>
    {
        self.productRepository.fetchProductDetail(of: productID)
            .map{ detail in
                return ProductDetailViewModel(product: detail) }
    }
    
    func readIsLikeProduct(of productID: Int) -> Observable<Bool> {
        return self.favoriteProductRepository.fetchIsLikeProduct(productID: productID)
    }
    
    func recordLikeProduct(of productID: Int) {
        self.favoriteProductRepository.createFavoriteProduct(productID: productID)
    }
    
    func recordUnlikeProduct(of productID: Int) {
        self.favoriteProductRepository.deleteFavoriteProduct(productID: productID)
    }
    
}
