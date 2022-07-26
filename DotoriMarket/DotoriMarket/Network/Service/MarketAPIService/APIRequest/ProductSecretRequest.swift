//
//  ProductSecretRequest.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

// MARK: - 상품 삭제 Secret 조회 / POST

struct ProductSecretRequest: APIRequest {
    
    typealias Response = String
    
    private let identifier: String
    private let productID: Int
    private let secret: String
    private let jsonParser = JSONCodable()
    var url: URL? {
        return MarketAPIURL.productSecret(productID).url
    }
    var httpMethod: HTTPMethod {
        return .post
    }
    var header: [String: String] {
        return [
            "identifier": identifier,
            "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return jsonParser.encode(from: secret)
    }
    
    init(identifier: String, productID: Int, secret: String) {
        self.identifier = identifier
        self.productID = productID
        self.secret = secret
    }
}
