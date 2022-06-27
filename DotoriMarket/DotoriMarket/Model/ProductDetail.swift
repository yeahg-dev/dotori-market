//
//  ProductDetail.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct ProductDetail: Codable, APIResponse {
    
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
    let vendor: Vendor
    let createdAt: Date
    let issuedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        
        case vendorID = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case vendor = "vendors"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case id, name, description, thumbnail, currency, price, stock, images
    }
}
