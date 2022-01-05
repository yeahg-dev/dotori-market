//
//  APIRequest.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

enum HTTPMethod: String {
    
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol APIRequest {

    associatedtype APIResponse: Decodable
    
    var method: HTTPMethod { get }
    var baseURLString: String { get }
    var path: String { get }
    var query: [String: Int] { get }
    var body: Data? { get }
    var headers: [String: String] { get }
    var responseType: APIResponse.Type { get }

}
