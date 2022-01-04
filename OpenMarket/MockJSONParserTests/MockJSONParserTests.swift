//
//  MockJSONParserTests.swift
//  MockJSONParserTests
//
//  Created by 유재호 on 2022/01/04.
//

import XCTest
@testable import OpenMarket

class MockJSONParserTests: XCTestCase {

    var sut: ProductsListPage!
    let mockJSONName = "products"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockJSONParser<ProductsListPage>.decode(from: mockJSONName)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func test_mockJSON_Date타입_파싱_검증() {
        let result = sut.pages[0].createdAt
        let expectation = "2022-01-03T00:00:00.00"
//        let expectation = formatDate(from: "2022-01-03T00:00:00.00")
        XCTAssertEqual(result, expectation)
    }
}

func formatDate(from date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS" // "2022-01-04T00:00:00.00"
    return dateFormatter.date(from: date) ?? Date()
}
