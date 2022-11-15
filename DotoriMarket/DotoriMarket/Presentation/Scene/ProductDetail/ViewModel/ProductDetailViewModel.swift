//
//  ProductDetailViewModel.swift
//  DotoriMarket
//
//  Created by lily on 2022/06/24.
//

import Foundation

struct ProductDetailViewModel {
    
    // MARK: - Model data
    
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
            return String(self.discountedPriceData)
        }
    }
    
    var discountedRate: String? {
        if self.discountedPriceData.isZero {
            return nil
        }
        
        let discountRate = self.discountedPriceData / self.priceData
        return discountRate.formattedPercent
    }
    
    var sellingPrice: String {
        return self.toProductSellingPriceLabelText(
            bargainPrice: self.bargainPriceData,
            currency: self.currency)
    }
    
    var price: String? {
        return self.toProductPriceLabelText(
            price: self.priceData,
            currency: self.currency)
    }
    
    var stock: String {
        return self.toProductStockLabelText(stock: self.stockData)
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

extension ProductDetailViewModel {
    
    private func toProductPriceLabelText(
        price: Double,
        currency: Currency)
    -> String?
    {
        if price.isZero {
            return nil
        }
        
        let price = price.decimalFormatted
        return currency.composePriceTag(of: price)
    }
    
    private func toProductSellingPriceLabelText(
        bargainPrice: Double,
        currency: Currency)
    -> String
    {
        let price = bargainPrice.decimalFormatted
        return currency.composePriceTag(of: price)
    }
    
    private func toProductStockLabelText(stock: Int) -> String {
        if stock == .zero {
            return MarketCommonNamespace.soldout.rawValue
        }
        let stockFormatted = stock.decimalFormatted
        return "\(MarketCommonNamespace.remainingStock.rawValue) \(stockFormatted)"
    }
    
}
