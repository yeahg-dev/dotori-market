//
//  APIRequest.swift
//  DotoriMarket
//
//  Created by 예거 on 2022/01/11.
//

import Foundation

protocol APIRequest {
    
    associatedtype Response: ResponseDataType
    
    var url: URL? { get }
    var httpMethod: HTTPMethod { get }
    var header: [String: String] { get }
    var body: Data? { get }
    
}

extension APIRequest {
    
    func urlRequest() -> URLRequest? {
        guard let url = url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = body
        return urlRequest
    }
    
}
