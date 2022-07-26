//
//  EditProductInfo.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/05.
//

import Foundation

struct EditProductInfo: Encodable {
    
    let name: String?
    let descriptions: String?
    let thumbnailID: Double?
    let price: Double?
    let currency: CurrencyResponse?
    let discountedPrice: Double?
    let stock: Int?
    let secret: String
    
    private enum CodingKeys: String, CodingKey {
        case thumbnailID = "thumbnail_id"
        case discountedPrice = "discounted_price"
        case name, descriptions, price, currency, stock, secret
    }
}
