//
//  MockURLSessionTests.swift
//  MockJSONParserTests
//
//  Created by lily on 2022/01/11.
//

import XCTest
@testable import OpenMarket

class MockURLSessionTests: XCTestCase {
    var sut: APIExecutor!
    let jsonParser = JSONCodable()

    override func setUpWithError() throws {
        sut = APIExecutor(session: MockURLSession())
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_상품리스트조회API를_호출했을때_pages의_id를_20을_가져오는지() {
        let expectResponse: ProductsListPage! = jsonParser.decode(from: "products")
        let expectation = expectResponse.pages[0].id
        
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        sut.execute(request) { result in
            switch result {
            case .success(let data):
                let decodedData: ProductsListPage! = self.jsonParser.decode(from: data)
                XCTAssertEqual(expectation, decodedData.pages[0].id )
            case .failure:
                XCTFail()
            }
        }
    }
    
}
