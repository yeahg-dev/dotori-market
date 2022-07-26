//
//  CurrencyResponse.swift
//  DotoriMarket
//
//  Created by lily on 2022/01/04.
//

import Foundation

enum CurrencyResponse: String, Codable {
    
    case krw = "KRW"
    case usd = "USD"
}

extension CurrencyResponse {
    
    func toDomain() -> Currency {
        switch self {
        case .krw:
            return Currency.krw
        case .usd:
            return Currency.usd
        }
    }
}
