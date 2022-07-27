//
//  ProductDeletionRequest.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

// MARK: - 상품 삭제 / DELETE

struct ProductDeletionRequest: APIRequest {
    
    typealias Response = ProductDetailResponse
    
    private let identifier: String
    private let productID: Int
    private let productSecret: String
    var url: URL? {
        return MarketAPIURL.productDeletion(productID, productSecret).url
    }
    var httpMethod: HTTPMethod {
        return .delete
    }
    var header: [String: String] {
        return [
            "identifier": identifier,
            "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return nil
    }
    
    init(identifier: String, productID: Int, productSecret: String) {
        self.identifier = identifier
        self.productID = productID
        self.productSecret = productSecret
    }
}
