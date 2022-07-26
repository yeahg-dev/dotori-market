//
//  Currency.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/05.
//

import Foundation

enum Currency {
    
    case krw
    case usd
    
    func composePriceTag(of price: String) -> String {
        switch self {
        case .krw:
            return "\(price)원"
        case .usd:
            return "$\(price)"
        }
    }
    
}

extension Currency {
    
    func toEntity() -> CurrencyResponse {
        switch self {
        case .krw:
            return CurrencyResponse.krw
        case .usd:
            return CurrencyResponse.usd
        }
    }
}
