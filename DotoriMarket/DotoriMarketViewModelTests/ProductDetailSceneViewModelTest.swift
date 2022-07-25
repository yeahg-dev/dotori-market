//
//  ProductDetailSceneViewModelTest.swift
//  DotoriMarketViewModelTests
//
//  Created by 1 on 2022/07/06.
//

import XCTest
@testable import DotoriMarket

import RxSwift
import RxTest

class ProductDetailSceneViewModelTest: XCTestCase {
    
    private var sut: ProductDetailSceneViewModel!
    private let scheduler = TestScheduler(initialClock: 0)
    private let disposeBag = DisposeBag()
    let apiURL = URL(string: "https://[serverURL]")!
    private let dummyJSONData = """
    {
        "id": 522,
        "vendor_id": 6,
        "name": "아이폰13",
        "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/thumb/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
        "currency": "KRW",
        "price": 1300000,
        "description": "비싸",
        "bargain_price": 1300000,
        "discounted_price": 0,
        "stock": 12,
        "created_at": "2022-01-18T00:00:00.00",
        "issued_at": "2022-01-18T00:00:00.00",
        "images": [
          {
            "id": 352,
            "url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/origin/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
            "thumbnail_url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/thumb/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
            "succeed": true,
            "issued_at": "2022-01-18T00:00:00.00"
          }
        ],
        "vendors": {
          "name": "제인",
          "id": 6,
          "created_at": "2022-01-10T00:00:00.00",
          "issued_at": "2022-01-10T00:00:00.00"
        }
      }
    """.data(using: .utf8)!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: configuration)
        let mockAPIService = MarketAPIService(urlSession: mockURLSession)
        let testUsecase = LookProductDetaiUsecase(service: mockAPIService)
        self.sut = ProductDetailSceneViewModel(usecase: testUsecase)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func test_viewWillAppear가_호출되면_ProductDetail을_APIService로부터받아_포맷데이터를_뷰에전달(){
        let expectation = XCTestExpectation()
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, self.dummyJSONData)
        }
        
        let trigger = PublishSubject<Int>()
        let input = ProductDetailSceneViewModel.Input(
            viewWillAppear: trigger.asObservable(),
            productDidLike: trigger.asObservable(),
            productDidUnlike: trigger.asObservable())
        let output = sut.transform(input: input)
        
        let productNameObserver = scheduler.createObserver(String.self)
        let productSellingPriceObserver = scheduler.createObserver(String.self)
        
        output.prdouctName
            .do(afterNext: { _ in
                expectation.fulfill() })
            .drive(productNameObserver)
            .disposed(by: disposeBag)
                
        output.prodcutSellingPrice
            .do(afterNext: { _ in
                expectation.fulfill() })
            .drive(productSellingPriceObserver)
            .disposed(by: disposeBag)
                    
        self.scheduler.createColdObservable([(.next(5, 1000))])
            .bind(to: trigger)
            .disposed(by: disposeBag)
                    
        self.scheduler.start()
                    
        wait(for: [expectation], timeout: 10)
                    
        XCTAssertEqual(productNameObserver.events, [.next(5, "아이폰13")])
        XCTAssertEqual(productSellingPriceObserver.events, [.next(5, "1,300,000원")])
    }
    
}
