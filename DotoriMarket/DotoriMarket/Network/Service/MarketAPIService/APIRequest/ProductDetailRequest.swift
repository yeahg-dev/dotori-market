//
//  ProductDetailRequest.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

// MARK: - 상품 상세 조회 / GET

struct ProductDetailRequest: APIRequest {

    typealias Response = ProductDetailResponse
    
    private let productID: Int
    private let boundary: String
    var url: URL? {
        return MarketAPIURL.productDetail(productID).url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var header: [String: String] {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    var body: Data? {
        return nil
    }
    
    init(productID: Int) {
        self.productID = productID
        self.boundary = "--\(UUID().uuidString)"
    }
}
