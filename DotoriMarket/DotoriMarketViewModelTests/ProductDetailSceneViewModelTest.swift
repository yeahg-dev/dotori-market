//
//  ProductDetailSceneViewModelTest.swift
//  DotoriMarketViewModelTests
//
//  Created by lily on 2022/07/06.
//

import XCTest
@testable import DotoriMarket

import RxSwift
import RxTest
import RealmSwift

class ProductDetailSceneViewModelTest: XCTestCase {
    
    private var sut: ProductDetailSceneViewModel!
    private let scheduler = TestScheduler(initialClock: 0)
    private let disposeBag = DisposeBag()
    let apiURL = MarketAPIURL.productDetail(522).url!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: configuration)
        let mockAPIService = MarketAPIService(urlSession: mockURLSession)
        let mockProductRepository = MarketProductRepository(service: mockAPIService)
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let mockFavoriteRepository = MarketFavoriteProductRepository()
        let testUsecase = LookProductDetaiUsecase(
            productRepository: mockProductRepository, favoriteProductRepository: mockFavoriteRepository)
        
        self.sut = ProductDetailSceneViewModel(usecase: testUsecase)
    }
  
    func test_viewWillAppear가_호출되면_ProductDetail을_APIService로부터받아_포맷데이터를_뷰에전달(){
        let expectation = XCTestExpectation()
        
        let dummyJSONData = DummyJson.productDetailResponse
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, dummyJSONData)
        }
        
        let trigger = PublishSubject<Int>()
        let input = ProductDetailSceneViewModel.Input(
            viewWillAppear: trigger.asObservable(),
            productDidLike: trigger.asObservable(),
            productDidUnlike: trigger.asObservable())
        let output = sut.transform(input: input)
        
        let productNameObserver = scheduler.createObserver(String.self)
        let productSellingPriceObserver = scheduler.createObserver(String.self)
        let likeButtonObserver = scheduler.createObserver(Bool.self)
        
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
                
        output.isLikeProduct
        .do(afterNext: { _ in
            expectation.fulfill() })
        .drive(likeButtonObserver)
        .disposed(by: disposeBag)
                
        self.scheduler.createColdObservable([(.next(5, 1000))])
            .bind(to: trigger)
            .disposed(by: disposeBag)
                    
        self.scheduler.start()
                    
        wait(for: [expectation], timeout: 10)
                    
        XCTAssertEqual(productNameObserver.events, [.next(5, "아이폰13")])
        XCTAssertEqual(productSellingPriceObserver.events, [.next(5, "1,300,000원")])
        XCTAssertEqual(likeButtonObserver.events, [.next(5, false)])
            
    }
    
}
