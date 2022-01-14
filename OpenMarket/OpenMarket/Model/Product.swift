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
        if discountedPrice == .zero {
            let originalPrice = NSAttributedString(
                string: currency.rawValue + .whiteSpace + price.formatted,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
            return originalPrice
        } else {
            let originalPrice = NSAttributedString(
                string: currency.rawValue + .whiteSpace + price.formatted,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemRed,
                             .strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            let bargainPrice = NSAttributedString(
                string: currency.rawValue + .whiteSpace + bargainPrice.formatted,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .callout),
                             .foregroundColor: UIColor.systemGray]
            )
            let priceTag = NSMutableAttributedString(attributedString: originalPrice)
            priceTag.append(.whiteSpace)
            priceTag.append(bargainPrice)
            return priceTag
        }
    }
    
    var attributedStock: NSAttributedString {
        switch stock {
        case .zero:
            let soldOut = NSAttributedString(
                string: "품절",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .headline),
                             .foregroundColor: UIColor.systemYellow]
            )
            return soldOut
        default:
            let remainStock = NSAttributedString(
                string: "잔여수량 : \(stock)",
                attributes: [.font: UIFont.preferredFont(forTextStyle: .body),
                             .foregroundColor: UIColor.systemGray]
            )
            return remainStock
        }
    }
}
