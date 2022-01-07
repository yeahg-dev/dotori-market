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

enum APIRequest {
    
    typealias Handler = (Result<Data, Error>) -> Void
    
    static let parser = Parser()
    static let boundary = "--\(UUID().uuidString)"
    
    static func requestHealthChecker() {
        guard let url = APIURL.healthChecker.url else { return }
        let request = URLRequest(url: url)
        execute(request: request, nil)
    }
    
    static func requestProductRegistration(
        identifier: String,
        params: NewProductInfo,
        images: [ImageFile],
        _ completion: @escaping Handler
    ) {
        guard let url = APIURL.productRegistration.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("multipart/form-data; boundary=\(boundary)" , forHTTPHeaderField: "Content-Type")
        
        let body = createBody(params: params, images: images)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    static func requestProductEdit(
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
        
        let body = parser.encode(from: body)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    static func requestProductSecret(
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
        
        let body = parser.encode(from: secret)
        request.httpBody = body
        
        execute(request: request, completion)
    }
    
    static func requestProductDeletion(
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
    
    static func execute(request: URLRequest, _ completion: Handler?) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completion?(.failure(APIError.invalidResponseDate))
                      return
                  }
            
            guard let data = data else { return }
            completion?(.success(data))
        }
        dataTask.resume()
    }
    
    static func createBody(params productInfo: NewProductInfo, images: [ImageFile]) -> Data? {
        var body = Data()
        let lineBreak = "\r\n"
        
        let params = "Content-Disposition: form-data; name=\"params\"\(lineBreak)"
        guard let encodedProductInfo = parser.encode(from: productInfo) else {
            return nil
        }
        body.appendString(params)
        body.append(encodedProductInfo)
        body.appendString("\(lineBreak)\(lineBreak)")

        images.forEach { imageFile in
            body.appendString("Content-Disposition: form-data; name=\(imageFile.key); filename=\(imageFile.fileName)\(lineBreak)")
            body.appendString("Content-Type: \(imageFile.type.description)\(lineBreak)")
            body.appendString("\(imageFile.data)\(lineBreak)")
        }
        
        body.appendString("\(boundary)--")
        return body
    }
}
