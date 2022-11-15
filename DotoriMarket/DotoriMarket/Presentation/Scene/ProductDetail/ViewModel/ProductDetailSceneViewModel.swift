//
//  ProductDetailSceneViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/25.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductDetailSceneViewModel {
    
    private let usecase: ProductDetaiUsecase
    private let disposeBag = DisposeBag()
    
    init(usecase: ProductDetaiUsecase) {
        self.usecase = usecase
    }
    
    struct Input {
        let viewWillAppear: Observable<Int>
        let productDidLike: Observable<Int>
        let productDidUnlike: Observable<Int>
    }
    
    struct Output {
        let prdouctName: Driver<String>
        let productImagesURL: Driver<[String]>
        let productPrice: Driver<String?>
        let prodcutSellingPrice: Driver<String>
        let productDiscountedRate: Driver<String?>
        let productStock: Driver<String>
        let productDescription: Driver<String>
        let isLikeProduct: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.productDidLike
            .subscribe{ productID in
                self.usecase.recordLikeProduct(of: productID) }
            .disposed(by: disposeBag)
        
        input.productDidUnlike
            .subscribe { productID in
                self.usecase.recordUnlikeProduct(of: productID)}
            .disposed(by: disposeBag)

        let productDetail = input.viewWillAppear
            .flatMap({ id in
                self.usecase.fetchPrdouctDetail(of: id) })
            .share(replay: 1)
        
        let isLikeProduct = productDetail.flatMap { detail in
            self.usecase.readIsLikeProduct(of: detail.id) }
            .asDriver(onErrorJustReturn: false)
        
        let productName = productDetail.map{ $0.name }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let productPrice = productDetail.map{ $0.price }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let productSellingPrice = productDetail.map{ $0.sellingPrice }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let productDiscountedRate = productDetail.map{ $0.discountedRate }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let productStock = productDetail.map{ $0.stock }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let prodcutDescription = productDetail.map{ $0.description }
            .asDriver(onErrorJustReturn: MarketCommonNamespace.downloadErrorPlacehodler.rawValue)
        let productImageURLs = productDetail.map{ $0.images }
            .map{ $0.map{ $0.thumbnailURL } }
            .asDriver(onErrorJustReturn: [])
        
        return Output(prdouctName: productName,
                      productImagesURL: productImageURLs,
                      productPrice: productPrice,
                      prodcutSellingPrice: productSellingPrice,
                      productDiscountedRate: productDiscountedRate,
                      productStock: productStock,
                      productDescription: prodcutDescription,
                      isLikeProduct: isLikeProduct)
    }
}
