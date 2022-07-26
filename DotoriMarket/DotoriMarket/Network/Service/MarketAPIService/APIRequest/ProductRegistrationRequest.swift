//
//  ProductRegistrationRequest.swift
//  DotoriMarket
//
//  Created by 1 on 2022/07/26.
//

import Foundation

// MARK: - 상품 등록 / POST

struct ProductRegistrationRequest: APIRequest {
    
    typealias Response = ProductDetailResponse
    
    private let identifier: String
    private let params: NewProductInfo
    private let images: [ImageFile?]
    private let boundary: String
    var url: URL? {
        return MarketAPIURL.productRegistration.url
    }
    var httpMethod: HTTPMethod {
        return .post
    }
    var header: [String: String] {
        return [
            "identifier": identifier,
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
    }
    var body: Data? {
        return createBody(params: params, images: images, encodingStyle: .utf8)
    }
    
    init(identifier: String, params: NewProductInfo, images: [ImageFile?]) {
        self.identifier = identifier
        self.params = params
        self.images = images
        self.boundary = UUID().uuidString
    }
    
    private func createBody(
        params productInfo: NewProductInfo,
        images: [ImageFile?],
        encodingStyle: String.Encoding
    ) -> Data? {
        var body = Data()
        let boundary = "--" + boundary
        let lineBreak = "\r\n"
        guard let encodedProductInfo = JSONCodable().encode(from: productInfo) else {
            return nil
        }
        
        body.append(boundary + lineBreak, using: encodingStyle)
        body.append(
            "Content-Disposition: form-data; name=\"params\"" + lineBreak,
            using: encodingStyle
        )
        body.append("Content-Type: application/json" + lineBreak, using: encodingStyle)
        body.append(lineBreak, using: encodingStyle)
        body.append(encodedProductInfo)
        body.append(lineBreak + lineBreak, using: encodingStyle)

        for image in images {
            guard let image = image, let data = image.data else {
                continue
            }
            body.append(boundary + lineBreak, using: encodingStyle)
            body.append(
                "Content-Disposition: form-data; name=\"images\"; filename=\"\(image.fileName + image.type.rawValue)\"" + lineBreak,
                using: encodingStyle
            )
            body.append(
                "Content-Type: " + image.type.description + lineBreak,
                using: encodingStyle
            )
            body.append(lineBreak, using: encodingStyle)
            body.append(data)
            body.append(lineBreak + lineBreak, using: encodingStyle)
        }
        
        body.append(boundary + "--", using: encodingStyle)
        return body
    }
}
