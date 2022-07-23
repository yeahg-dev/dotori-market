//
//  ProductListViewModel.swift
//  OpenMarket
//
//  Created by 1 on 2022/06/17.
//

import UIKit

struct ProductViewModel {
    
    // MARK: - Model data
    
    private let currencyData: Currency
    private let priceData: Double
    private let bargainPriceData: Double
    private let discountedPriceData: Double
    private let stockData: Int
    
    // MARK: - View Model
    
    let id: Int
    let name: String
    let thumbnail: String

    var sellingPrice: String {
        if discountedPriceData.isZero {
            return currencyData.composePriceTag(of: self.priceData.decimalFormatted)
        } else {
            return currencyData.composePriceTag(of: self.bargainPriceData.decimalFormatted)
        }
    }
    
    var discountedRate: String? {
        if self.discountedPriceData.isZero {
            return nil
        }
        let discountRate = self.discountedPriceData / self.priceData
        return discountRate.formattedPercent
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

// MARK: - Extension

extension ProductViewModel {
    
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
