//
//  ProductsListPageRequest.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/26.
//

import Foundation

// MARK: - 상품 리스트 조회 / GET

struct ProductsListPageRequest: APIRequest {
    
    typealias Response = ProductsListPageResponse
    
    private let pageNo: Int
    private let itemsPerPage: Int
    private let searchValue: String?
    private let boundary: String
    var url: URL? {
        return MarketAPIURL.productsListPage(pageNo, itemsPerPage, searchValue).url
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
    
    init(pageNo: Int, itemsPerPage: Int, searchValue: String?) {
        self.pageNo = pageNo
        self.itemsPerPage = itemsPerPage
        self.searchValue = searchValue
        self.boundary = "--\(UUID().uuidString)"
    }
}
