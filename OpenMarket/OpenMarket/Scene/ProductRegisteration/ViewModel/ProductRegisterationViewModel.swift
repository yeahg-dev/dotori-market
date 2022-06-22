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
    private let isValidImage = BehaviorSubject(value: false)
    private let textViewPlaceHolder = "상품 상세 정보를 입력해주세요.\n(최소 10 ~ 최대 1,000 글자 작성 가능 😊)"
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let itemSelected: Observable<Int>
        let didSelectImage: Observable<UIImage>
        let productTitle: Observable<String?>
        let productPrice: Observable<String?>
        let prdouctDiscountedPrice: Observable<String?>
        let productStock: Observable<String?>
        let productDescriptionText: Observable<String?>
        let requestRegisteration: Observable<Void>
    }
    
    struct Output {
        let textViewPlaceholder: Observable<String>
        let presentImagePicker: Observable<Void>
        let productImages: Observable<[(CellType, UIImage)]>
        let excessImageAlert: Observable<ExecessImageAlertViewModel>
        let inputValidationAlert: Observable<String?>
        let registerationResponse: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let textViewPlaceholderText = self.textViewPlaceHolder
        
        let textViewPlaceholder = input.viewWillAppear
            .map {textViewPlaceholderText }
        
        let presentImagePicker = input.itemSelected
            .share(replay: 1)
            .filter { row in
                row == .zero && self.productImages.count < self.maximutProductImageCellCount }
            .map { _ in }
        
        let didSelectImage = input.didSelectImage
            .do(onNext: { image in
                self.productImages.append((.productImageCell,image))
                self.isValidImage.onNext(true) })
                .map { _ in }
        
        let productImages = Observable.merge(input.viewWillAppear, didSelectImage)
            .map { _ in self.productImages }
        
        let excessImageAlert = input.itemSelected
            .filter { row in
                row == .zero && self.productImages.count >= self.maximutProductImageCellCount }
            .map { _ in ExecessImageAlertViewModel() }
        
        // validation
        let isValidName = self.validate(name: input.productTitle).share(replay: 1)
        let isValidPrice = self.validate(price: input.productPrice).share(replay: 1)
        let isValidStock = self.validate(stock: input.productStock).share(replay: 1)
        let isvalidDescription = self.validate(description: input.productDescriptionText).share(replay: 1).debug()
        
        let validation = Observable.combineLatest(isValidImage, isValidName, isValidPrice, isValidStock, isvalidDescription, resultSelector: {
            self.validateInputResult(isValidImage: $0, isValidName: $1, isValidPrice: $2, isValidStock: $3, isValidDescription: $4)})
            .filter { (result: ValidationResult, description: String?) in
                result == .failure }
            .map { (result, desccriptioin) in
                return desccriptioin }
        
        let inputValidationResult = input.requestRegisteration.withLatestFrom(validation)
    
        // request
        let registerationResponse = Observable.just("")
        
        return Output(textViewPlaceholder: textViewPlaceholder,
                      presentImagePicker: presentImagePicker,
                      productImages: productImages,
                      excessImageAlert: excessImageAlert,
                      inputValidationAlert: inputValidationResult,
                      registerationResponse: registerationResponse)
    }
    
}

extension ProductRegisterationViewModel {
    
    struct ExecessImageAlertViewModel {
        let title: String? = "사진은 최대 \(ProductRegisterationViewModel.maximumProductImageCount)장까지 첨부할 수 있어요"
        let message: String? = nil
        let actionTitle: String? = "확인"
    }
    
    enum ValidationResult {
        
        case success
        case failure
    }
    
    private func validateInputResult(isValidImage: Bool, isValidName: Bool, isValidPrice: Bool,
                                     isValidStock: Bool, isValidDescription: Bool) -> (ValidationResult, String?) {
        let category = [isValidImage, isValidName, isValidPrice, isValidStock, isValidDescription]
        
        if category.contains(false) {
            let description = self.makeAlertDescription(isValidImage: isValidImage, isValidName: isValidName, isValidPrice: isValidPrice, isValidStock: isValidStock, isValidDescription: isValidDescription)
            return (ValidationResult.failure, description)
        } else {
            return (ValidationResult.success, nil)
        }
    }
    
    private func makeAlertDescription(isValidImage: Bool, isValidName: Bool, isValidPrice: Bool,
                                      isValidStock: Bool, isValidDescription: Bool) -> String {
        let image = isValidImage ? "" : "대표 사진"
        let name = isValidName ? "" : "상품명"
        let price = isValidPrice ? "" : "가격"
        let stock = isValidStock ? "" : "재고"
        let description = isValidDescription ? "" : "상세정보"
        
        if isValidName == true && isValidPrice == true
            && isValidStock == true && isValidDescription == false {
            return "상세정보는 10자이상 1,000자이하로 작성해주세요"
        } else {
            let categories = [image, name, price, stock, description]
           
            let description = categories
                .filter { !$0.isEmpty }
                .reduce("") { partialResult, category in
                    partialResult.isEmpty ? category : "\(partialResult), \(category)"
                }
            
            if isValidDescription == false || isValidStock == false {
                return "\(description)는 필수 입력 항목이에요"
            } else {
                return "\(description)은 필수 입력 항목이에요"
            }
        }
    }
    
    private func validate(name: Observable<String?>) -> Observable<Bool> {
        return name.map { name -> Bool in
            guard let name = name else { return false }
            return name.isEmpty ? false : true
        }
    }
    
    private func validate(price: Observable<String?>) -> Observable<Bool> {
        return price.map { price -> Bool in
            guard let price = price else { return false }
            return price.isEmpty ? false : true
        }
    }
    
    private func validate(stock: Observable<String?>) -> Observable<Bool> {
        return stock.map { stock -> Bool in
            guard let stock = stock else { return false }
            return stock.isEmpty ? false : true
        }
    }
    
    private func validate(description: Observable<String?>) -> Observable<Bool> {
        return description.map { description -> Bool in
            guard let text = description else { return false }
            if text == self.textViewPlaceHolder { return false }
            return text.count >= 10 && text.count <= 1000 ? true : false
        }
    }
    
}
