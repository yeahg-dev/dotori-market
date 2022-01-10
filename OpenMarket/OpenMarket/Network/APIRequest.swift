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

final class APIRequest: APIRequestProtocol {
    
    private let jsonParser: JSONCodable
    
    init(jsonParser: JSONCodable = JSONCodable()) {
        self.jsonParser = jsonParser
    }
    
    func requestHealthChecker() {
        guard let url = APIURL.healthChecker.url else { return }
        let request = URLRequest(url: url)
        execute(request: request, nil)
    }
    
    func requestProductRegistration(
        identifier: String,
        params: NewProductInfo,
        images: [ImageFile],
        _ completion: @escaping Handler
    ) {
        let boundary = boundary
        guard let url = APIURL.productRegistration.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("multipart/form-data; boundary=\(boundary)" , forHTTPHeaderField: "Content-Type")
        
        let body = createBody(params: params, images: images, boundary: boundary)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    func requestProductEdit(
        identifier: String,
        productID: Int,
        body: EditProductInfo,
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productInfoEdit(productID).url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.patch.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = jsonParser.encode(from: body)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    func requestProductSecret(
        identifier: String,
        productID: Int,
        secret: String,
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productSecret(productID).url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = jsonParser.encode(from: secret)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    func requestProductDeletion(
        identifier: String,
        productID: Int,
        productSecret: String,
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productDeletion(productID, productSecret).url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        execute(request: request, completion)
    }
    
    func requestProductDetail(
        productID: Int,
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productDetail(productID).url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        execute(request: request, completion)
    }
    
    func requestProductsListPage(
        pageNo: Int,
        itemsPerPage: Int,
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productsListPage(pageNo, itemsPerPage).url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        execute(request: request, completion)
    }
}
