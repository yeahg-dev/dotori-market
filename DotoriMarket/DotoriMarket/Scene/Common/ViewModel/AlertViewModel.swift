//
//  AlertViewModel.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/10.
//

import Foundation

protocol AlertViewModel {
    
    var title: String? { get }
    var message: String? { get }
    var actionTitle: String? { get }
}

struct ErrorAlertViewModel: AlertViewModel {
    
    var title: String? = "오류가 발생했어요"
    var message: String? = "다시 시도해주세요🙏🏻"
    var actionTitle: String? = MarketCommon.confirm.rawValue
    
}
