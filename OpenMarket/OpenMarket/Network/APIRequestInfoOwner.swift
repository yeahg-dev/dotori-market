//
//  APIRequestInfoOwner.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/05.
//

import Foundation

protocol APIRequestInfoOwner { }

extension APIRequestInfoOwner {
    
    var baseURLString: String {
        "https://market-training.yagom-academy.kr"
    }
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "UUID-register": "cd706a3e-66db-11ec-9626-796401f2341a",
            "UUID-delete": "80c47530-58bb-11ec-bf7f-d188f1cd5f22"
        ]
    }
}
