//
//  ProductRegisterationViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/20.
//

import Foundation
import RxSwift

final class ProductRegisterationViewModel {
    
    private let APIService = MarketAPIService()
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let textViewPlaceholder: Observable<String>
    }
    
    func transform(input: Input) -> Output {
      
        let textViewPlaceholderText = "상품 상세 정보를 입력해주세요.\n(최소 10 ~ 최대 1,000 글자 작성 가능 😊)"
        
        let textViewPlaceholder = input.viewWillAppear
            .map {textViewPlaceholderText }
        
        return Output(textViewPlaceholder: textViewPlaceholder)
    }
    
}
