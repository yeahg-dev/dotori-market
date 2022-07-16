//
//  ProductEditSceneAlertViewModel.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/11.
//

import Foundation

extension ProductEditSceneViewModel {
    
    struct RequireSecretAlertViewModel: AlertViewModel {
        
        var title: String? = "판매자 비밀번호를 입력해주세요"
        var message: String?
        var actionTitle: String?  = "수정"
    }
    
    struct RequestFailureAlertViewModel: AlertViewModel {
        
        var title: String? = "수정에 실패했습니다"
        var message: String? = "다시 시도 해주세요"
        var actionTitle: String? = "확인"
    }
    
    struct ValidationFailureAlertViewModel: AlertViewModel {
        
        var title: String?
        var message: String? = "다시 시도 해주세요"
        var actionTitle: String? = "확인"
    }
    
}
