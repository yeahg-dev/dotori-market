//
//  ProductsListPageRequest.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

// MARK: - 상품 리스트 조회 / GET

struct ProductsListPageRequest: APIRequest {
    
    typealias Response = ProductsListPageResponse
    
    private let pageNo: Int
    private let itemsPerPage: Int
    private let boundary: String
    var url: URL? {
        return MarketAPIURL.productsListPage(pageNo, itemsPerPage).url
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
    
    init(pageNo: Int, itemsPerPage: Int) {
        self.pageNo = pageNo
        self.itemsPerPage = itemsPerPage
        self.boundary = "--\(UUID().uuidString)"
    }
}
