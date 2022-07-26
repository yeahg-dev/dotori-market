//
//  EditProductUsecase.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

import RxSwift

struct EditProductUsecase {
    
    private let productRepository: ProductRepository
    
    init(productRepository: MarketProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func fetchPrdouctDetail(
        of productID: Int) -> Observable<ProductDetail> {
        return self.productRepository.fetchProductDetail(of: productID)
    }
    
    func requestProductEdit(with request: ProductEditRequest) -> Observable<ProductDetail> {
        return self.productRepository.requestProductEdit(with: request)
    }
    
}
