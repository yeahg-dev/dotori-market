//
//  ProductDetailSceneViewModelTest.swift
//  DotoriMarketViewModelTests
//
//  Created by 1 on 2022/07/06.
//

import XCTest
import RxSwift
import RxTest
@testable import DotoriMarket

class ProductDetailSceneViewModelTest: XCTestCase {
    
    private let dummyResponse: ProductDetailResponse = ProductDetailResponse(id: 0,
                                                                            vendorID: 0,
                                                                            name: "pizza",
                                                                            description: "real pizza, JMT",
                                                                            thumbnail: "",
                                                                            currency: .usd,
                                                                            price: 40000,
                                                                            bargainPrice: 30000,
                                                                            discountedPrice: 10000,
                                                                            stock: 0,
                                                                            images: [],
                                                                            vendor: VendorResponse(name: "PizzaHouse", id: 1, createdAt: Date(), issuedAt: Date()),
                                                                            createdAt: Date(),
                                                                            issuedAt: Date())
    private lazy var mockAPIService = MockMarketAPIService()
    private var sut: ProductDetailSceneViewModel!
    private let scheduler = TestScheduler(initialClock: 0)
    private let disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.mockAPIService.mockResponse = dummyResponse
        self.sut = ProductDetailSceneViewModel(APIService: mockAPIService)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockAPIService.mockResponse = nil
    }
    
    func test_viewWillAppear가_호출되면_ProductDetail을_APIService로부터받아_포맷데이터를_뷰에전달(){
        let trigger = PublishSubject<Int>()
        let input = ProductDetailSceneViewModel.Input(viewWillAppear: trigger.asObservable())
        
        let productNameObserver = scheduler.createObserver(String.self)
        let proudctSellingPriceObserver = scheduler.createObserver(String.self)
        
        let output = sut.transform(input: input)
        
        output.prdouctName
            .bind(to: productNameObserver)
            .disposed(by: disposeBag)
        
        output.prodcutSellingPrice
            .bind(to: proudctSellingPriceObserver)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([(.next(10, 100))])
            .bind(to: trigger)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(productNameObserver.events, [.next(10, "pizza")])
        XCTAssertEqual(proudctSellingPriceObserver.events, [.next(10, "$30,000")])
    }

}
