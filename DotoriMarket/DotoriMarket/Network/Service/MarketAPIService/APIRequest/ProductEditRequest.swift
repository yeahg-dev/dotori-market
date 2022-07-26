//
//  ProductEditRequest.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

// MARK: - 상품 수정 / PATCH

struct ProductEditRequest: APIRequest {
    
    typealias Response = ProductDetailResponse
    
    private let identifier: String
    private let productID: Int
    private let productInfo: EditProductInfo
    private let jsonParser = JSONCodable()
    var url: URL? {
        return MarketAPIURL.productInfoEdit(productID).url
    }
    var httpMethod: HTTPMethod {
        return .patch
    }
    var header: [String: String] {
        return ["identifier": identifier,
                "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return jsonParser.encode(from: productInfo)
    }
    
    init(identifier: String, productID: Int, productInfo: EditProductInfo) {
        self.identifier = identifier
        self.productID = productID
        self.productInfo = productInfo
    }
}
