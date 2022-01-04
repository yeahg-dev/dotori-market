//
//  ProductsListPage.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/04.
//

import Foundation

struct ProductsListPage: Codable {
    
    let pageNo: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [Product]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
}
