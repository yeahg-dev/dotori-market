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
    let mockJSONName = "products"

    override func setUpWithError() throws {
        sut = APIExecutor(session: MockURLSession())
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_헬스체크API_호출시_OK받아오는지() {
        let request = HealthCheckerRequest()
        APIExecutor().execute(request) { result in // 진짜 URLSession 으로 request 보냄
            switch result { // switch문 타질 않음
            case .success(let data):
                let health = String(data: data, encoding: .utf8)
                XCTAssertEqual(health, "??????") // 이상한 String 넣어도 테스트 성공함
            case .failure:
                XCTFail()
            }
        }
    }
    
    func test_상품리스트조회API_호출시_pages의_id_20을_가져오는지() {
        let expectResponse: ProductsListPage! = jsonParser.decode(from: mockJSONName)
        let expectation = expectResponse.pages[0].id
        
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        sut.execute(request) { result in
            switch result { // switch문 타질 않음
            case .success(let data):
                let decodedData: ProductsListPage! = self.jsonParser.decode(from: data)
                XCTAssertEqual(expectation, decodedData.pages[0].id )
            case .failure:
                XCTFail()
            }
        }
    }
}
