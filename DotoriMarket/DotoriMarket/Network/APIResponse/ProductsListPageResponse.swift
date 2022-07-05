//
//  ProductsListPageResponse.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/04.
//

import Foundation

struct ProductsListPageResponse: Codable, ResponseDataType {
    
    let pageNo: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [ProductResponse]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
    
    private enum CodingKeys: String, CodingKey {
        
        case pageNo = "page_no"
        case itemsPerPage = "items_per_page"
        case totalCount = "total_count"
        case lastPage = "last_page"
        case hasNext = "has_next"
        case hasPrev = "has_prev"
        case offset, limit, pages
    }
}

extension ProductsListPageResponse {

    func toDomain() -> ProductListPage {
        return ProductListPage(pages: self.pages.map{$0.toDomain()},
                               hasNext: self.hasNext)
    }
}
