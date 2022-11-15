//
//  ErrorAlertViewModel.swift
//  DotoriMarket
//
//  Created by Moon Yeji on 2022/11/15.
//

import Foundation

struct ErrorAlertViewModel: AlertViewModel {
    
    var title: String? = "오류가 발생했어요"
    var message: String? = "다시 시도해주세요🙏🏻"
    var actionTitle: String? = MarketCommonNamespace.confirm.rawValue
    
}
