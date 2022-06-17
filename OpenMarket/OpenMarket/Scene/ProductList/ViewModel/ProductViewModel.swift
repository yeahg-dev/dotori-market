//
//  ProductListViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/17.
//

import Foundation
import UIKit

struct ProductViewModel {
    
    private let currencyData: Currency
    private let priceData: Double
    private let bargainPriceData: Double
    private let discountedPriceData: Double
    private let stockData: Int
    
    let id: Int
    let name: String
    let thumbnail: String

    var price: NSAttributedString {
        return self.toAttributedPrice(discountedPrice: self.discountedPriceData,
                                      price: self.priceData,
                                      currency: self.currencyData)
    }
    
    var bargainPrice: NSAttributedString {
        return self.toAttributedBargainPrice(discountedPrice: self.discountedPriceData,
                                             bargainPrice: self.bargainPriceData,
                                             currency: self.currencyData)
    }
    
    var stock: NSAttributedString {
        return self.toAttributedStock(stock: self.stockData)
    }
    
    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.thumbnail = product.thumbnail
        self.currencyData = product.currency
        self.priceData = product.price
        self.bargainPriceData = product.bargainPrice
        self.discountedPriceData = product.discountedPrice
        self.stockData = product.stock
    }
}

extension ProductViewModel {
    
    private func toAttributedPrice(discountedPrice: Double, price: Double, currency: Currency) -> NSAttributedString {
        let attributedPrice: NSAttributedString
        if discountedPrice == .zero {
            attributedPrice = NSAttributedString(
                string: currency.composePriceTag(of: price.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
        } else {
            attributedPrice = NSAttributedString(
                string: currency.composePriceTag(of: price.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemRed,
                             .strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
        return attributedPrice
    }
    
    private func toAttributedBargainPrice(discountedPrice: Double, bargainPrice: Double, currency: Currency) -> NSAttributedString {
        let attributedBargainPrice: NSAttributedString
        if discountedPrice == .zero {
            attributedBargainPrice = NSAttributedString(string: .empty)
        } else {
            attributedBargainPrice = NSAttributedString(
                string: currency.composePriceTag(of: bargainPrice.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
        }
        return attributedBargainPrice
    }
    
    private func toAttributedStock(stock: Int) -> NSAttributedString {
        switch stock {
        case .zero:
            let soldOut = NSAttributedString(
                string: MarketCommon.soldout.rawValue,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .headline),
                             .foregroundColor: UIColor.systemYellow]
            )
            return soldOut
        default:
            let remainStock = NSAttributedString(
                string: "\(MarketCommon.remainingStock.rawValue) \(stock.decimalFormatted)",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .body),
                             .foregroundColor: UIColor.systemGray]
            )
            return remainStock
        }
    }
}
