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
    
    static let parser = Parser()
    
    static func requestHealthChecker() {
        guard let url = APIURL.healthChecker.url else { return }
        let request = URLRequest(url: url)
        execute(request: request, nil)
    }
    
    static func requestProductRegistration(
        identifier: String,
        params: NewProductInfo,
        images: [String: Data],
        _ completion: (Result<Data, Error>) -> Void
    ) {
        guard let url = APIURL.productRegistration.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        // body 만들어야 함
    }
    
//    static func body(with productInfo: NewProductInfo, images: [ImageFile]) -> Data? {
//
//        guard let newLine = "\r\n".data(using: .utf8) else {
//            return nil
//        }
//        guard let encodedProductInfo = parser.encode(from: productInfo) else {
//            return nil
//        }
//
//        var body = Data()
//
//        let paramsString = "Content-Disposition: form-data; name=\"params\"\r\n\r\n"
//        let imageString = "Content-Disposition: form-data; name=\"images\"; filename=\(fileName)\r\n"
//        guard let paramsBody = paramsString.data(using: .utf8) else {
//            return nil
//        }
//
//        body.append(paramsBody)
//        body.append(encodedProductInfo)
//
//        // 딕셔너리 타입 images 의 조건을 검증한다.
//        // 상품 이미지 파일, png , jpeg, jpg 만 지원, 최소 1, 최대 5
//
//        images.joined()
//
//    }
    
//    private func buildBody(with salesInformation: NewProductInfo, images: [String: Data] ) -> Data? {
//
//            images.forEach { (fileName, image) in
//                var imagesBody = ""
//                imagesBody.append("\r\n--\(boundary)\r\n")
//                imagesBody.append(
//                    "Content-Disposition: form-data; name=\"images\"; filename=\(fileName)\r\n"
//                )
//                guard let imagesBody = imagesBody.data(using: .utf8) else { return }
//                data.append(imagesBody)
//                data.append(newLine)
//                data.append(image)
//            }
//            data.append(endBoundary)
//            return data
//        }
    
    static func execute(request: URLRequest, _ completion: ((Result<Data, Error>) -> Void)?) {
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
}
