//
//  MockJSONParserTests.swift
//  MockJSONParserTests
//
//  Created by 예거 on 2022/01/04.
//

import XCTest
@testable import OpenMarket

class MockJSONParserTests: XCTestCase {

    var sut: ProductsListPage!
    let jsonParser = JSONCodable()
    let mockJSONName = "products"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = jsonParser.decode(from: mockJSONName)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    private func formatDate(from date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        return dateFormatter.date(from: date) ?? Date()
    }
    
    func test_mockJSON_Date타입_파싱_검증() {
        let result = sut.pages[0].createdAt
        let expectation = formatDate(from: "2022-01-03T00:00:00.000")
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_currencyCode_연산프로퍼티_검증() {
        let result = sut.pages[1].currency
        let expectation = Currency.krw
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_thumbnail_파싱_검증() {
        let result = sut.pages[2].thumbnail
        let expectation = "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/2/thumb/f70ad56a689911ecbf33f11af721febf.png"
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_pageNo_파싱_검증() {
        let result = sut.pageNo
        let expectation = 1
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_hasNext_파싱_검증() {
        let result = sut.hasNext
        XCTAssertFalse(result)
    }
}

