//
//  APIURL.swift
//  OpenMarket
//
//  Created by lily on 2022/01/06.
//

import Foundation

enum APIURL {

    private static let openMarketAPIHost = "https://market-training.yagom-academy.kr/"

    case healthChecker
    case productRegistration
    case productInfoEdit(_ productID: Int)
    case productSecret(_ productID: Int)
    case productDeletion(_ productID: Int, _ productSecret: String)
    case productDetail(_ productID: Int)
    case productsListPage(_ pageNo: Int, _ itemsPerPage: Int)

    var url: URL? {
        switch self {
        case .healthChecker:
            return URL(string: Self.openMarketAPIHost + "healthChecker")
        case .productRegistration:
            return URL(string: Self.openMarketAPIHost + "api/products")
        case .productInfoEdit(let productID):
            return URL(string: Self.openMarketAPIHost + "api/products/\(productID)")
        case .productSecret(let productID):
            return URL(string: Self.openMarketAPIHost + "api/products/\(productID)/secret")
        case .productDeletion(let productID, let productSecret):
            return URL(string: Self.openMarketAPIHost + "api/products/\(productID)/\(productSecret)")
        case .productDetail(let productID):
            return URL(string: Self.openMarketAPIHost + "api/products/\(productID)")
        case .productsListPage(let pageNo, let itemsPerPage):
            var urlComponents = URLComponents(string: Self.openMarketAPIHost + "api/products")
            let pageNo = URLQueryItem(name: "page_no", value: "\(pageNo)")
            let itemsPerPage = URLQueryItem(name: "items_per_page", value: "\(itemsPerPage)")
            urlComponents?.queryItems = [pageNo, itemsPerPage]
            return urlComponents?.url
        }
    }
}
