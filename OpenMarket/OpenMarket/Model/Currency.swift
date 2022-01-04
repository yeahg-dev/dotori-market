//
//  Currency.swift
//  OpenMarket
//
//  Created by lily on 2022/01/04.
//

import Foundation

enum Currency: String {
    
    case krw = "KRW"
    case usd = "USD"
    
    init?(currencyCode: String) {
        self.init(rawValue: currencyCode)
    }
}
