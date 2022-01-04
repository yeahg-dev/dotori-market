//
//  Product.swift
//  OpenMarket
//
//  Created by lily on 2022/01/04.
//

import Foundation

struct Product {
    
    let id: Int
    let vendorId: Int
    let name: String
    let thumbnail: String
    let currency: String
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String
}
