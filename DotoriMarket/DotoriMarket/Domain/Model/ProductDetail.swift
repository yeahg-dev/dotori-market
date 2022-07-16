//
//  ProductDetail.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct ProductDetail {
    
    let id: Int
    let vendorID: Int
    let name: String
    let description: String
    let thumbnail: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let images: [Image]
}
