//
//  NetworkTests.swift
//  MockJSONParserTests
//
//  Created by 1 on 2022/01/17.
//

import XCTest
@testable import OpenMarket

class NetworkTests: XCTestCase {
    
    let sut = APIExecutor()
    
    func test_상품을_잘_등록하는지(){
//        let expectation = XCTestExpectation(description: "productRegisteration")
//        let productInfo: NewProductInfo = NewProductInfo(name: "우융", descriptions: "🥲", price: 10000, currency: .krw, discountedPrice: 0, stock: 0, secret: "password")
//        let imageURL = URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTT62Xu708gysotCNssb0mEh0hanIU0_c93g&usqp=CAU")!
//        let cat = try! Data(contentsOf: imageURL)
//        let image = ImageFile(fileName: "우유123", data: cat , type: .jpeg)
//        let request = ProductRegistrationRequest(identifier: "cd706a3e-66db-11ec-9626-796401f2341a", params: productInfo, images: [image])
//        sut.execute(request) { (result: Result<ProductDetail, Error>) in
//            switch result {
//            case .success(let detail):
//                XCTAssertEqual("우융", detail.name)
//            case .failure(let error):
//                XCTAssertThrowsError(error)
//            }
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 7.0)
    }
    
}
