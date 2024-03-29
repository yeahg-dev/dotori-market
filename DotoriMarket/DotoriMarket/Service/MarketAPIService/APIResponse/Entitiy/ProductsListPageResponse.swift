//
//  ProductsListPageResponse.swift
//  DotoriMarket
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
        
        case pageNo
        case itemsPerPage
        case totalCount
        case lastPage
        case hasNext
        case hasPrev
        case offset, limit, pages
    }
}

extension ProductsListPageResponse {

    func toDomain() -> ProductListPage {
        return ProductListPage(pages: self.pages.map{ $0.toDomain() },
                               hasNext: self.hasNext)
    }
}
