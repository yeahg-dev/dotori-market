//
//  APIRequestType.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

// MARK: - HealthChekcer / GET
struct HealthCheckerRequest: APIRequest {
    
    typealias Response = String
    
    var url: URL? {
        return APIURL.healthChecker.url
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

// MARK: - 상품 등록 / POST
struct ProductRegistrationRequest: APIRequest {
    
    typealias Response = ProductDetail
    
    private let identifier: String
    private let params: NewProductInfo
    private let images: [ImageFile]
    private let boundary: String
    var url: URL? {
        return APIURL.productRegistration.url
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
    
    init(identifier: String, params: NewProductInfo, images: [ImageFile]) {
        self.identifier = identifier
        self.params = params
        self.images = images
        self.boundary = UUID().uuidString
    }
    
    private func createBody(
        params productInfo: NewProductInfo,
        images: [ImageFile],
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

        images.forEach { imageFile in
            body.append(boundary + lineBreak, using: encodingStyle)
            body.append(
                "Content-Disposition: form-data; name=\"images\"; filename=\"\(imageFile.fileName + imageFile.type.rawValue)\"" + lineBreak,
                using: encodingStyle
            )
            body.append(
                "Content-Type: " + imageFile.type.description + lineBreak,
                using: encodingStyle
            )
            body.append(lineBreak, using: encodingStyle)
            guard let data = imageFile.data else { return }
            body.append(data)
            body.append(lineBreak + lineBreak, using: encodingStyle)
        }
        
        body.append(boundary + "--", using: encodingStyle)
        return body
    }
}

// MARK: - 상품 수정 / PATCH
struct ProductEditRequest: APIRequest {
    
    typealias Response = ProductDetail
    
    private let identifier: String
    private let productID: Int
    private let productInfo: EditProductInfo
    private let jsonParser = JSONCodable()
    var url: URL? {
        return APIURL.productInfoEdit(productID).url
    }
    var httpMethod: HTTPMethod {
        return .patch
    }
    var header: [String: String] {
        return ["identifier": identifier,
                "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return jsonParser.encode(from: productInfo)
    }
    
    init(identifier: String, productID: Int, productInfo: EditProductInfo) {
        self.identifier = identifier
        self.productID = productID
        self.productInfo = productInfo
    }
}

// MARK: - 상품 삭제 Secret 조회 / POST
struct ProductSecretRequest: APIRequest {
    
    typealias Response = String
    
    private let identifier: String
    private let productID: Int
    private let secret: String
    private let jsonParser = JSONCodable()
    var url: URL? {
        return APIURL.productSecret(productID).url
    }
    var httpMethod: HTTPMethod {
        return .post
    }
    var header: [String: String] {
        return [
            "identifier": identifier,
            "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return jsonParser.encode(from: secret)
    }
    
    init(identifier: String, productID: Int, secret: String) {
        self.identifier = identifier
        self.productID = productID
        self.secret = secret
    }
}

// MARK: - 상품 삭제 / DELETE
struct ProductDeletionRequest: APIRequest {
    
    typealias Response = ProductDetail
    
    private let identifier: String
    private let productID: Int
    private let productSecret: String
    var url: URL? {
        return APIURL.productDeletion(productID, productSecret).url
    }
    var httpMethod: HTTPMethod {
        return .delete
    }
    var header: [String: String] {
        return [
            "identifier": identifier,
            "Content-Type": "application/json"
        ]
    }
    var body: Data? {
        return nil
    }
    
    init(identifier: String, productID: Int, productSecret: String) {
        self.identifier = identifier
        self.productID = productID
        self.productSecret = productSecret
    }
}

// MARK: - 상품 상세 조회 / GET
struct ProductDetailRequest: APIRequest {

    typealias Response = ProductDetail
    
    private let productID: Int
    private let boundary: String
    var url: URL? {
        return APIURL.productDetail(productID).url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var header: [String: String] {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    var body: Data? {
        return nil
    }
    
    init(productID: Int) {
        self.productID = productID
        self.boundary = "--\(UUID().uuidString)"
    }
}

// MARK: - 상품 리스트 조회 / GET
struct ProductsListPageRequest: APIRequest {
    
    typealias Response = ProductsListPage
    
    private let pageNo: Int
    private let itemsPerPage: Int
    private let boundary: String
    var url: URL? {
        return APIURL.productsListPage(pageNo, itemsPerPage).url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var header: [String: String] {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    var body: Data? {
        return nil
    }
    
    init(pageNo: Int, itemsPerPage: Int) {
        self.pageNo = pageNo
        self.itemsPerPage = itemsPerPage
        self.boundary = "--\(UUID().uuidString)"
    }
}
