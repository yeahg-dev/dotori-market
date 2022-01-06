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
}

struct EditProductInfo: Encodable {
    
    let name: String?
    let descriptions: String?
    let thumbnailID: String?
    let price: Double?
    let currency: Currency?
    let discountedPrice: Double = 0
    let stock: Int = 0
    let secret: String
}
