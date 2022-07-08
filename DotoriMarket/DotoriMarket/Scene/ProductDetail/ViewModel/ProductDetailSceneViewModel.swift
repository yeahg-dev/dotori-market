//
//  ProductDetailSceneViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/25.
//

import Foundation

import RxSwift

final class ProductDetailSceneViewModel {
    
    private var APIService: APIServcie
    
    init(APIService: APIServcie) {
        self.APIService = APIService
    }
    
    struct Input {
        let viewWillAppear: Observable<Int>
    }
    
    struct Output {
        let prdouctName: Observable<String>
        let productImagesURL: Observable<[Image]> 
        let productPrice: Observable<String?>
        let prodcutSellingPrice: Observable<String>
        let productDiscountedRate: Observable<String?>
        let productStock: Observable<String>
        let productDescription: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let productDetail = input.viewWillAppear
            .map{ productID in
                ProductDetailRequest(productID: productID) }
            .flatMap{ request -> Observable<ProductDetailResponse> in
                self.APIService.requestRx(request) }
            .map{ $0.toDomain() }
            .map{ ProductDetailViewModel(product: $0) }
            .share(replay: 1)
        
        let productName = productDetail.map{ $0.name }
        let productPrice = productDetail.map{ $0.price }
        let productSellingPrice = productDetail.map{ $0.sellingPrice }
        let productDiscountedRate = productDetail.map{ $0.discountedRate }
        let productStock = productDetail.map{ $0.stock }
        let prodcutDescription = productDetail.map{ $0.description }
        let productImages = productDetail.map{ $0.images }
        
        return Output(prdouctName: productName,
                      productImagesURL: productImages,
                      productPrice: productPrice,
                      prodcutSellingPrice: productSellingPrice,
                      productDiscountedRate: productDiscountedRate,
                      productStock: productStock,
                      productDescription: prodcutDescription)
    }
}
