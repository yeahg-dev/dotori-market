//
//  ProductModificationSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/26.
//

import Foundation
import RxSwift

final class ProductModificationSceneViewModel {
    
    private let APIService = MarketAPIService()
    
    struct Input {
        let viewWillAppear: Observable<Int>
    }
    
    struct Output {
        let prdouctName: Observable<String>
        let productImagesURL: Observable<[Image]>
        let productPrice: Observable<String?>
        let prodcutDiscountedPrice: Observable<String?>
        let productCurrencyIndex: Observable<Int>
        let productStock: Observable<String>
        let productDescription: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let productDetail = input.viewWillAppear
            .map { productID in
                ProductDetailRequest(productID: productID) }
            .flatMap { request -> Observable<ProductDetail> in
                self.APIService.requestRx(request) }
            .map { productDetail in
                ProductDetailViewModel(product: productDetail) }
            .share(replay: 1)
        
        let productName = productDetail.map { $0.name }
        let productPrice = productDetail.map { $0.price }
        let productDiscountedPrice = productDetail.map { $0.discountedPrice }
        let productStock = productDetail.map { $0.stock }
        let prodcutDescription = productDetail.map { $0.description }
        let productImages = productDetail.map { $0.images }
        let productCurrencyIndex = productDetail.map { $0.currency }
            .map { currency -> Int in
                switch currency {
                case .krw:
                    return 0
                case .usd:
                    return 1
                }
            }
        
        return Output(prdouctName: productName,
                      productImagesURL: productImages,
                      productPrice: productPrice,
                      prodcutDiscountedPrice: productDiscountedPrice,
                      productCurrencyIndex: productCurrencyIndex,
                      productStock: productStock,
                      productDescription: prodcutDescription)
    }
}
