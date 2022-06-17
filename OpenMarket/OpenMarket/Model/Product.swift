//
//  Product.swift
//  OpenMarket
//
//  Created by lily on 2022/01/04.
//

import UIKit

struct Product: Codable {
    
    let id: Int
    let vendorID: Int
    let name: String
    let thumbnail: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: Date
    let issuedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        
        case vendorID = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case id, name, thumbnail, currency, price, stock
    }
}

extension Product {
    
    var attributedName: NSAttributedString {
        return NSAttributedString(
            string: name,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .headline)]
        )
    }
    
    var attributedPrice: NSAttributedString {
        let originalPrice: NSAttributedString
        if discountedPrice == .zero {
            originalPrice = NSAttributedString(
                string: currency.composePriceTag(of: price.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
        } else {
            originalPrice = NSAttributedString(
                string: currency.composePriceTag(of: price.decimalFormatted),
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemRed,
                             .strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
        return originalPrice
    }
    
    var attributedBargainPrice: NSAttributedString {
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
    
    var attributedStock: NSAttributedString {
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
