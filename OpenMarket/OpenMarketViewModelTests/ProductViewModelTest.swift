//
//  OpenMarketViewModelTests.swift
//  OpenMarketViewModelTests
//
//  Created by 1 on 2022/06/18.
//

import XCTest
@testable import OpenMarket

class ProductViewModelTest: XCTestCase {
    
    let mockProduct = Product(id: 12345,
                          vendorID: 12345,
                          name: "맥북에어",
                          thumbnail: "https://www.apple.com/kr/macbook-air-m2/a/images/overview/design/design_top_midnight__codbsd86bjxy_large_2x.jpg",
                          currency: Currency.krw,
                          price: 1690000,
                          bargainPrice: 1689000,
                          discountedPrice: 1000,
                          stock: 9999,
                          createdAt: Date(),
                          issuedAt: Date())

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func test_생성자() {
        let viewModel = ProductViewModel(product: mockProduct)
        
        XCTAssertNotNil(viewModel)
    }
    
    func test_currency가_krw일때_price_화폐단위_변환() {
        let viewModel = ProductViewModel(product: mockProduct)
        let priceResult = viewModel.price.string
        let bargainPriceResult = viewModel.bargainPrice.string
        let priceExpectation = "1,690,000원"
        let bargainPriceExpectation = "1,689,000원"
        
        XCTAssertEqual(priceResult, priceExpectation)
        XCTAssertEqual(bargainPriceResult, bargainPriceExpectation)
    }
    
    func test_currency가_usd일때_price_화폐단위_변환() {
        let product = Product(id: 12345,
                              vendorID: 12345,
                              name: "맥북에어",
                              thumbnail: "https://www.apple.com/kr/macbook-air-m2/a/images/overview/design/design_top_midnight__codbsd86bjxy_large_2x.jpg",
                              currency: Currency.usd,
                              price: 1690,
                              bargainPrice: 1680,
                              discountedPrice: 10,
                              stock: 9999,
                              createdAt: Date(),
                              issuedAt: Date())
        let viewModel = ProductViewModel(product: product)
        let priceResult = viewModel.price.string
        let bargainPriceResult = viewModel.bargainPrice.string
        let priceExpectation = "$1,690"
        let bargainPriceExpectation = "$1,680"
        
        XCTAssertEqual(priceResult, priceExpectation)
        XCTAssertEqual(bargainPriceResult, bargainPriceExpectation)
    }
    
    func test_stock이_0일때_SOLDOUT변환() {
        let product = Product(id: 12345,
                              vendorID: 12345,
                              name: "맥북에어",
                              thumbnail: "https://www.apple.com/kr/macbook-air-m2/a/images/overview/design/design_top_midnight__codbsd86bjxy_large_2x.jpg",
                              currency: Currency.usd,
                              price: 1690,
                              bargainPrice: 1680,
                              discountedPrice: 10,
                              stock: 0,
                              createdAt: Date(),
                              issuedAt: Date())
        let viewModel = ProductViewModel(product: product)
        let result = viewModel.stock.string
        let expectation = "SOLD OUT"
        
        XCTAssertEqual(result, expectation)
    }
    
    func test_stock이_3자리수_이상일때_쉼표추가() {
        let product = Product(id: 12345,
                              vendorID: 12345,
                              name: "맥북에어",
                              thumbnail: "https://www.apple.com/kr/macbook-air-m2/a/images/overview/design/design_top_midnight__codbsd86bjxy_large_2x.jpg",
                              currency: Currency.usd,
                              price: 1690,
                              bargainPrice: 1680,
                              discountedPrice: 10,
                              stock: 99999,
                              createdAt: Date(),
                              issuedAt: Date())
        let viewModel = ProductViewModel(product: product)
        let result = viewModel.stock.string
        let expectation = "잔여 수량 99,999"
        
        XCTAssertEqual(result, expectation)
    }
    
    func test_stock이_3자리수_이하일때_표시확인() {
        let product = Product(id: 12345,
                              vendorID: 12345,
                              name: "맥북에어",
                              thumbnail: "https://www.apple.com/kr/macbook-air-m2/a/images/overview/design/design_top_midnight__codbsd86bjxy_large_2x.jpg",
                              currency: Currency.usd,
                              price: 1690,
                              bargainPrice: 1680,
                              discountedPrice: 10,
                              stock: 99,
                              createdAt: Date(),
                              issuedAt: Date())
        let viewModel = ProductViewModel(product: product)
        let result = viewModel.stock.string
        let expectation = "잔여 수량 99"
        
        XCTAssertEqual(result, expectation)
    }

}
