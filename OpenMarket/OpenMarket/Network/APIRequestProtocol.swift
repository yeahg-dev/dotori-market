//
//  APIRequestProtocol.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation

protocol APIRequestProtocol: Parserable { }

extension APIRequestProtocol {
    
    typealias Handler = (Result<Data, Error>) -> Void
    
    static var boundary: String {
        return "--\(UUID().uuidString)"
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
        guard let encodedProductInfo = encode(from: productInfo) else {
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
