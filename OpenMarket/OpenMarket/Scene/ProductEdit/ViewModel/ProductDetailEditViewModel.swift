//
//  ProductDetailEditViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/26.
//

import Foundation

struct ProductDetailEditViewModel {
    
    // MARK: - Model Data
    private let priceData: Double
    private let bargainPriceData: Double
    private let discountedPriceData: Double
    private let stockData: Int
    
    // MARK: - View Model
    let id: Int
    let name: String
    let description: String
    let images: [Image]
    let currency: Currency
    
    var discountedPrice: String? {
        if self.discountedPriceData.isZero {
            return nil
        } else {
            return self.discountedPriceData.stringFormmated
        }
    }
    
    var price: String? {
        return self.priceData.stringFormmated
    }
    
    var stock: String {
        return String(self.stockData)
    }
    
    init(product: ProductDetail) {
        self.currency = product.currency
        self.priceData = product.price
        self.bargainPriceData = product.bargainPrice
        self.discountedPriceData = product.discountedPrice
        self.stockData = product.stock
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.images = product.images
    }
}
