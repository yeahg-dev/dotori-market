//
//  ProductInputChecker.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/11.
//

import Foundation

import RxSwift

struct ProductInputChecker {
    
    enum ValidationResult: Equatable {
        
        case success
        case failure
    }
    
    func isVald(image: Observable<[(CellType, Data)]>) -> Observable<Bool> {
        return image.map { $0.count > 1 && $0.count < 7 }
    }
    
    func isValid(name: Observable<String?>) -> Observable<Bool> {
        return name.map{ name -> Bool in
            guard let name = name else { return false }
            return name.isEmpty ? false : true }
    }
    
    func isValid(price: Observable<String?>) -> Observable<Bool> {
        return price.map{ price -> Bool in
            guard let price = price else { return false }
            return price.isEmpty ? false : true }
    }
    
    func isValid(stock: Observable<String?>) -> Observable<Bool> {
        return stock.map{ stock -> Bool in
            guard let stock = stock else { return false }
            return stock.isEmpty ? false : true }
    }
    
    func isValid(description: Observable<String?>) -> Observable<Bool> {
        return description.map{ description -> Bool in
            guard let text = description else { return false }
            if text == MarketCommonNamespace.descriptionTextViewPlaceHolder.rawValue { return false }
            return text.count >= 10 && text.count <= 1000 ? true : false }
    }
    
    func isValid(
        discountedPrice: Observable<String?>,
        price: Observable<String?>)
    -> Observable<Bool>
    {
        return Observable.combineLatest(discountedPrice, price) { (discountedPrice, price) -> Bool in
            let disconutPrice = Int(discountedPrice ?? "") ?? 0
            let price = Int(price ?? "") ?? 0
            return disconutPrice <= price
        }
    }
    
    func validationResultOf(
        isValidImage: Bool = true,
        isValidName: Bool,
        isValidPrice: Bool,
        isValidStock: Bool,
        isValidDescription: Bool,
        isValidDiscountedPrice: Bool)
    -> (ValidationResult, String?)
    {
        let category = [isValidImage, isValidName, isValidPrice, isValidStock, isValidDescription, isValidDiscountedPrice]
        
        if !isValidDiscountedPrice {
            return (ValidationResult.failure, "할인금액은 상품가격보다 클 수 없습니다.")
        }
        
        if category.contains(false) {
            let description = self.alertDescriptionOf(
                isValidImage: isValidImage,
                isValidName: isValidName,
                isValidPrice: isValidPrice,
                isValidStock: isValidStock,
                isValidDescription: isValidDescription)
            return (ValidationResult.failure, description)
        } else {
            return (ValidationResult.success, nil)
        }
    }
    
    private func alertDescriptionOf(
        isValidImage: Bool,
        isValidName: Bool,
        isValidPrice: Bool,
        isValidStock: Bool,
        isValidDescription: Bool)
    -> String
    {
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
            
            let categoryRepresentation = categories
                .filter{ !$0.isEmpty }
                .reduce("") { partialResult, category in
                    partialResult.isEmpty ? category : "\(partialResult), \(category)" }
            
            if isValidDescription == false || isValidStock == false {
                return "\(categoryRepresentation)는 필수 입력 항목이에요"
            } else {
                return "\(categoryRepresentation)은 필수 입력 항목이에요"
            }
        }
    }
    
}
