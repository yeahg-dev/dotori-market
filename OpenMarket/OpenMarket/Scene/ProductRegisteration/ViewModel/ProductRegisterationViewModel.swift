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
    static let maximumProductImageCount = 5
    private lazy var maximutProductImageCellCount = ProductRegisterationViewModel.maximumProductImageCount + 1
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let itemSelected: Observable<Int>
        let didSelectImage: Observable<UIImage>
    }
    
    struct Output {
        let textViewPlaceholder: Observable<String>
        let presentImagePicker: Observable<Void>
        let productImages: Observable<[(CellType, UIImage)]>
        let excessImageAlert: Observable<ExecessImageAlert>
    }
    
    func transform(input: Input) -> Output {
      
        let textViewPlaceholderText = "상품 상세 정보를 입력해주세요.\n(최소 10 ~ 최대 1,000 글자 작성 가능 😊)"
        
        let textViewPlaceholder = input.viewWillAppear
            .map {textViewPlaceholderText }
        
        let presentImagePicker = input.itemSelected
            .share(replay: 1)
            .filter { row in
                row == .zero && self.productImages.count < self.maximutProductImageCellCount
            }
            .map { _ in }
        
        let didSelectImage = input.didSelectImage
            .do(onNext: { image in
                self.productImages.append((.productImageCell,image))} )
            .map { _ in }
                
        let productImages = Observable.merge(input.viewWillAppear, didSelectImage)
                            .map { _ in self.productImages }
        
        let excessImageAlert = input.itemSelected
            .filter { row in
                row == .zero && self.productImages.count >= self.maximutProductImageCellCount }
            .map { _ in ExecessImageAlert() }
        
        return Output(textViewPlaceholder: textViewPlaceholder,
                      presentImagePicker: presentImagePicker,
                      productImages: productImages,
                      excessImageAlert: excessImageAlert)
    }
    
}

extension ProductRegisterationViewModel {
    
    struct ExecessImageAlert {
        let title: String = "사진은 최대 \(ProductRegisterationViewModel.maximumProductImageCount)장까지 첨부할 수 있어요"
        let message: String? = nil
        let actionTitle: String = "확인"
    }
}
