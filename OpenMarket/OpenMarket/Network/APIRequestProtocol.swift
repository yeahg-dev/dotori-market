//
//  APIRequestProtocol.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation

protocol APIRequestProtocol { }

extension APIRequestProtocol {
    
    typealias Handler = (Result<Data, Error>) -> Void
    
    var boundary: String {
        return "--\(UUID().uuidString)"
    }
    
    func execute(request: URLRequest, _ completion: Handler?) {
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
    
    func createBody(params productInfo: NewProductInfo, images: [ImageFile], boundary: String) -> Data? {
        var body = Data()
        let boundary = boundary
        let lineBreak = "\r\n"
        let params = "Content-Disposition: form-data; name=\"params\""
        guard let encodedProductInfo = JSONCodable().encode(from: productInfo) else {
            return nil
        }
        
        body.append(boundary + lineBreak)
        body.append(params + lineBreak)
        body.append("Content-Type: application/json" + lineBreak)
        body.append(lineBreak)
        body.append(encodedProductInfo)
        body.append(lineBreak + lineBreak)

        images.forEach { imageFile in
            body.append(boundary + lineBreak)
            body.append("Content-Disposition: form-data; name=\(imageFile.key); filename=\(imageFile.fileName)" + lineBreak)
            body.append("Content-Type: " + imageFile.type.description + lineBreak)
            body.append(lineBreak)
            body.append(imageFile.data)
            body.append(lineBreak + lineBreak)
        }
        
        body.append(boundary + "--")
        return body
    }
}
