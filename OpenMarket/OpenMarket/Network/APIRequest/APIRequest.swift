//
//  APIRequest.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/11.
//

import Foundation

protocol APIRequest {
    
    var url: URL? { get }
    var httpMethod: HTTPMethod { get }
    var header: [String: String] { get }
    var body: Data? { get }
}
