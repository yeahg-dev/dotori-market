//
//  ProductRegistrationSceneAlertViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/11.
//

import Foundation

extension ProductRegistrationSceneViewModel {
    
    struct ValidationFailureAlertViewModel: AlertViewModel {
        
        var title: String?
        var message: String?
        var actionTitle: String?
    
    }
 
    struct ExecessImageAlertViewModel: AlertViewModel {
        
        var title: String? = "사진은 최대 \(ProductRegistrationSceneViewModel.maximumProductImageCount)장까지 첨부할 수 있어요"
        var message: String? = nil
        var actionTitle: String? = "확인"
    }
    
    struct RequireSecretAlertViewModel: AlertViewModel {
        
        var title: String? = "판매자 비밀번호를 입력해주세요"
        var actionTitle: String? = "등록"
        var message: String?
        
    }
    
    struct RegistrationSuccessAlertViewModel: AlertViewModel {
        
        var title: String? = "성공적으로 등록되었습니다"
        var message: String?
        var actionTitle: String? = "상품 리스토로 돌아가기"
    }
    
    struct RegistrationFailureAlertViewModel: AlertViewModel {
        
        var title: String? = "등록에 실패했습니다"
        var message: String? = "다시 시도 해주세요"
        var actionTitle: String? = "확인"
    }
    
    struct RegistrationSuccessWithParsingFailureAlertViewModel: AlertViewModel {
        
        var title: String? = "나의 상품 등록에 실패했습니다."
        var message: String? = "상품은 정상적으로 마켓에 등록되었으나, 내 상품으로 등록하는데는 실패했습니다. 개발자에게 문의해주세요"
        var actionTitle: String? = "확인"
    }
    
}
