//
//  ProductRegistrationUsecaseTest.swift
//  DotoriMarketUsecaseTests
//
//  Created by lily on 2022/07/30.
//

import XCTest
@testable import DotoriMarket

import RxSwift
import RxTest
import RealmSwift

class ProductRegistrationUsecaseTest: XCTestCase {
    
    private var sut: ProductRegistrationUsecase!
    private let scheduler = TestScheduler(initialClock: 0)
    private var disposeBag = DisposeBag()
    private let apiURL = MarketAPIURL.productRegistration.url!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: configuration)
        let mockAPIService = MarketAPIService(urlSession: mockURLSession)
        let mockProductRepository = MarketProductRepository(service: mockAPIService)
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let mockRegisteredProductRepository = MarketRegisteredProductRepository()
        
        self.sut = ProductRegistrationUsecase(
            productRepository: mockProductRepository,
            registredProductRepository: mockRegisteredProductRepository)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        self.sut = nil
        self.disposeBag = DisposeBag()
    }

    func test_discountedPrice가_price보다크면_검증_실패하는지() throws {
        let imageObservable = PublishSubject<[(CellType, Data)]>()
        let nameObeservable = PublishSubject<String?>()
        let priceObeservable = PublishSubject<String?>()
        let stockObeservable = PublishSubject<String?>()
        let descriptionObeservable = PublishSubject<String?>()
        let discountedPriceObeservable = PublishSubject<String?>()
      
        let validationResult = sut.isValidInput(
            image: imageObservable.asObservable(),
            name: nameObeservable.asObservable(),
            price: priceObeservable.asObservable(),
            stock: stockObeservable.asObservable(),
            description: descriptionObeservable.asObservable(),
            discountedPrice: discountedPriceObeservable.asObservable())
      
        self.scheduler.createColdObservable([.next(3, [(CellType.productImageCell, Data())])])
            .subscribe(imageObservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "상품명")])
            .subscribe(nameObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "1000")])
            .subscribe(priceObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "0")])
            .subscribe(stockObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "설명은 10글자 이상이어야해요")])
            .subscribe(descriptionObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "10000")])
            .subscribe(discountedPriceObeservable)
            .disposed(by: disposeBag)
        
        let observer = self.scheduler.createObserver(ProductInputChecker.ValidationResult.self)
        
        validationResult
            .map{ $0.0 }
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(
            observer.events,
            [.next(3, .failure)])
    }
    
    func test_descriptionText가_10자미만이면_검증_실패하는지() throws {
        let imageObservable = PublishSubject<[(CellType, Data)]>()
        let nameObeservable = PublishSubject<String?>()
        let priceObeservable = PublishSubject<String?>()
        let stockObeservable = PublishSubject<String?>()
        let descriptionObeservable = PublishSubject<String?>()
        let discountedPriceObeservable = PublishSubject<String?>()
      
        let validationResult = sut.isValidInput(
            image: imageObservable.asObservable(),
            name: nameObeservable.asObservable(),
            price: priceObeservable.asObservable(),
            stock: stockObeservable.asObservable(),
            description: descriptionObeservable.asObservable(),
            discountedPrice: discountedPriceObeservable.asObservable())
      
        self.scheduler.createColdObservable([.next(3, [(CellType.productImageCell, Data())])])
            .subscribe(imageObservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "상품명")])
            .subscribe(nameObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "1000")])
            .subscribe(priceObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "0")])
            .subscribe(stockObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "설명")])
            .subscribe(descriptionObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "500")])
            .subscribe(discountedPriceObeservable)
            .disposed(by: disposeBag)
        
        let observer = self.scheduler.createObserver(ProductInputChecker.ValidationResult.self)
        
        validationResult
            .map{ $0.0 }
            .debug()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(
            observer.events,
            [.next(3, .failure)])
    }
    
    func test_모든input을_조건에_맞게_보내면_검증_성공하는지() throws {
        
        let imageObservable = PublishSubject<[(CellType, Data)]>()
        let nameObeservable = PublishSubject<String?>()
        let priceObeservable = PublishSubject<String?>()
        let stockObeservable = PublishSubject<String?>()
        let descriptionObeservable = PublishSubject<String?>()
        let discountedPriceObeservable = PublishSubject<String?>()
      
        let validationResult = sut.isValidInput(
            image: imageObservable.asObservable(),
            name: nameObeservable.asObservable(),
            price: priceObeservable.asObservable(),
            stock: stockObeservable.asObservable(),
            description: descriptionObeservable.asObservable(),
            discountedPrice: discountedPriceObeservable.asObservable())
      
        self.scheduler.createColdObservable([.next(3, [(CellType.productImageCell, Data())])])
            .subscribe(imageObservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "상품명")])
            .subscribe(nameObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "1000")])
            .subscribe(priceObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "0")])
            .subscribe(stockObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "설명은 10자 이상이에요")])
            .subscribe(descriptionObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "500")])
            .subscribe(discountedPriceObeservable)
            .disposed(by: disposeBag)
        
        let observer = self.scheduler.createObserver(ProductInputChecker.ValidationResult.self)
        
        validationResult
            .map{ $0.0 }
            .debug()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(
            observer.events,
            [.next(3, .success)])
    }
    
    func test_상품등록을_요청하면_응답이_오는지() throws {
        let expectation = XCTestExpectation()
        let dummyJSONData = DummyJson.productDetailResponse
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: self.apiURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, dummyJSONData)
        }
        
        let nameObeservable = PublishSubject<String?>()
        let priceObeservable = PublishSubject<String?>()
        let currencyObservable = PublishSubject<Int>()
        let stockObeservable = PublishSubject<String?>()
        let descriptionObeservable = PublishSubject<String?>()
        let discountedPriceObeservable = PublishSubject<String?>()
        let secretObservable = PublishSubject<String>()
        let imageObservable = PublishSubject<[(CellType, Data)]>()
        
        let registeratinoResult = sut.requestProductRegistration(
            name: nameObeservable.asObservable(),
            price: priceObeservable.asObservable(),
            currency: currencyObservable.asObservable(),
            discountedPrice: discountedPriceObeservable.asObserver(),
            stock: stockObeservable.asObservable(),
            description: descriptionObeservable.asObservable(),
            secret: secretObservable.asObservable(),
            image: imageObservable.asObservable())
      
        self.scheduler.createColdObservable([.next(3, "상품명")])
            .subscribe(nameObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "1000")])
            .subscribe(priceObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, 0)])
            .subscribe(currencyObservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "0")])
            .subscribe(stockObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "설명은 10자 이상이에요")])
            .subscribe(descriptionObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable(
            [.next(3, "500")])
            .subscribe(discountedPriceObeservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, [(CellType.productImageCell, Data())])])
            .subscribe(imageObservable)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([.next(3, "secret")])
            .subscribe(secretObservable)
            .disposed(by: disposeBag)
        
        let observer = self.scheduler.createObserver(String.self)
        
        registeratinoResult
            .do(onNext: {_ in
                expectation.fulfill()})
            .map{ $0.name }
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(
            observer.events,
            [.next(3, "아이폰13")])
    }

}
