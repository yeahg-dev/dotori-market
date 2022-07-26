//
//  HealthCheckerRequest.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

// MARK: - HealthChekcer / GET

struct HealthCheckerRequest: APIRequest {
    
    typealias Response = String
    
    var url: URL? {
        return MarketAPIURL.healthChecker.url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var header: [String: String] {
        return [:]
    }
    var body: Data? {
        return nil
    }
}
