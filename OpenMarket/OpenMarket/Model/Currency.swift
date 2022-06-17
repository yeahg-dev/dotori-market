//
//  Currency.swift
//  OpenMarket
//
//  Created by lily on 2022/01/04.
//

import Foundation

enum Currency: String, Codable {
    
    case krw = "KRW"
    case usd = "USD"
}

extension Currency {
    
    func composePriceTag(of price: String) -> String {
        switch self {
        case .krw:
            return "\(price)원"
        case .usd:
            return "$\(price)"
        }
    }
    
}
