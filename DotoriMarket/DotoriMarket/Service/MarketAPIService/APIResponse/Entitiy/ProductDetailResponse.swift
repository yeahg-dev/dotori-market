//
//  ProductDetailResponse.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/05.
//

import Foundation

struct ProductDetailResponse: Codable, ResponseDataType {
    
    let id: Int
    let vendorID: Int
    let name: String
    let description: String
    let thumbnail: String
    let currency: CurrencyResponse
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let images: [ImageResponse]
    let vendors: VendorResponse
    let createdAt: Date
    let issuedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        
        case vendorID = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case id, name, description, thumbnail, currency, price, stock, images, vendors
    }
}

extension ProductDetailResponse {
    
    func toDomain() -> ProductDetail {
        return ProductDetail(id: self.id,
                             vendorID: self.vendorID,
                             name: self.name,
                             description: self.description,
                             thumbnail: self.thumbnail,
                             currency: self.currency.toDomain(),
                             price: self.price,
                             bargainPrice: self.bargainPrice,
                             discountedPrice: self.discountedPrice,
                             stock: self.stock,
                             images: self.images.map{ $0.toDomain() })
    }
  
}
