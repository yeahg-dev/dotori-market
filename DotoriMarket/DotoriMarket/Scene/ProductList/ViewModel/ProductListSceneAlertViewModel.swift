//
//  ProductListSceneAlertViewModel.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/11.
//

import Foundation

extension ProductListSceneViewModel {
    
    struct NetworkErrorAlertViewModel: AlertViewModel {
        
        var title: String? = "다시 시도해주세요😢"
        var message: String? = "통신 에러가 발생했어요"
        var actionTitle: String? = MarketCommon.confirm.rawValue
    }
}
