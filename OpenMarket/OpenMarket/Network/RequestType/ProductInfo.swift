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
    let discountedPrice: Double
    let stock: Int
    let secret: String
    
    init(name: String, descriptions: String, price: Double, currency: Currency, discountedPrice: Double = 0, stock: Int = 0, secret: String) {
        self.name = name
        self.descriptions = descriptions
        self.price = price
        self.currency = currency
        self.discountedPrice = discountedPrice
        self.stock = stock
        self.secret = secret
    }
}

struct EditProductInfo: Encodable {
    
    let name: String?
    let descriptions: String?
    let thumbnailID: String?
    let price: Double?
    let currency: Currency?
    let discountedPrice: Double
    let stock: Int
    let secret: String
    
    init(name: String?, descriptions: String?, thumbnailID: String?, price: Double?, currency: Currency?, discountedPrice: Double = 0, stock: Int = 0, secret: String) {
        self.name = name
        self.descriptions = descriptions
        self.thumbnailID = thumbnailID
        self.price = price
        self.currency = currency
        self.discountedPrice = discountedPrice
        self.stock = stock
        self.secret = secret
    }
}
