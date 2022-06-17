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
        let attributedPrice: NSAttributedString
        if discountedPriceData == .zero {
            attributedPrice = NSAttributedString(
                string: currencyData.composePriceTag(of: priceData.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
        } else {
            attributedPrice = NSAttributedString(
                string: currencyData.composePriceTag(of: priceData.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemRed,
                             .strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
        return attributedPrice
    }
    
    var bargainPrice: NSAttributedString {
        let attributedBargainPrice: NSAttributedString
        if discountedPriceData == .zero {
            attributedBargainPrice = NSAttributedString(string: .empty)
        } else {
            attributedBargainPrice = NSAttributedString(
                string: currencyData.composePriceTag(of: bargainPriceData.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
        }
        return attributedBargainPrice
    }
    
    var stock: NSAttributedString {
        switch stockData {
        case .zero:
            let soldOut = NSAttributedString(
                string: MarketCommon.soldout.rawValue,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .headline),
                             .foregroundColor: UIColor.systemYellow]
            )
            return soldOut
        default:
            let remainStock = NSAttributedString(
                string: "\(MarketCommon.remainingStock.rawValue) \(stockData.decimalFormatted)",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .body),
                             .foregroundColor: UIColor.systemGray]
            )
            return remainStock
        }
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
