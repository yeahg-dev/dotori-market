//
//  ProductRegisterationViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/20.
//

import Foundation
import RxSwift
import UIKit

final class ProductRegisterationViewModel {
    
    private let APIService = MarketAPIService()
    
    private var productImages: [(CellType, UIImage)] = [(.imagePickerCell, UIImage())]
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let didSelectImage: Observable<UIImage>
    }
    
    struct Output {
        let textViewPlaceholder: Observable<String>
        let productImages: Observable<[(CellType, UIImage)]>
    }
    
    func transform(input: Input) -> Output {
      
        let textViewPlaceholderText = "상품 상세 정보를 입력해주세요.\n(최소 10 ~ 최대 1,000 글자 작성 가능 😊)"
        
        let textViewPlaceholder = input.viewWillAppear
            .map {textViewPlaceholderText }
        
        let didAddedImage = input.didSelectImage
            .do(onNext: { image in
                self.productImages.append((.productImageCell,image))}
            )
            .map { _ in }
                
        let productImages = Observable.merge(input.viewWillAppear, didAddedImage)
                            .map { _ in self.productImages }
        
        return Output(textViewPlaceholder: textViewPlaceholder, productImages: productImages)
    }
    
}
