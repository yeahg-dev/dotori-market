//
//  RegisterProductUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

import RxSwift

struct RegisterProductUsecase {
    
    private let productRepository: ProductRepository
    
    init(productRepository: MarketProductRepository = MarketProductRepository()) {
        self.productRepository = productRepository
    }
    
    func requestRegisterProduct(reqeust: ProductRegistrationRequest) -> Observable<ProductDetail> {
        self.productRepository.requestProductRegisteration(with: reqeust)
    }
    
}
