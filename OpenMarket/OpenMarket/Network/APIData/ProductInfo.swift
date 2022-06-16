//
//  ProductInfo.swift
//  OpenMarket
//
//  Created by lily on 2022/01/06.
//

import Foundation

struct NewProductInfo: Encodable {
    
    let name: String
    let descriptions: String
    let price: Double
    let currency: Currency
    let discountedPrice: Double?
    let stock: Int?
    let secret: String
    
    private enum CodingKeys: String, CodingKey {
        case discountedPrice = "discounted_price"
        case name, descriptions, price, currency, stock, secret
    }
}

struct EditProductInfo: Encodable {
    
    let name: String?
    let descriptions: String?
    let thumbnailID: Double?
    let price: Double?
    let currency: Currency?
    let discountedPrice: Double?
    let stock: Int?
    let secret: String
    
    private enum CodingKeys: String, CodingKey {
        case thumbnailID = "thumbnail_id"
        case discountedPrice = "discounted_price"
        case name, descriptions, price, currency, stock, secret
    }
}
