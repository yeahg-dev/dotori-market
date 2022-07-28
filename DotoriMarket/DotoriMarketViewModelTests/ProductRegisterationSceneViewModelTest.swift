//
//  ProductRegisterationSceneViewModelTest.swift
//  DotoriMarketViewModelTests
//
//  Created by 1 on 2022/07/28.
//

import XCTest
@testable import DotoriMarket

import RxSwift
import RxCocoa
import RxTest
import RealmSwift

class ProductRegisterationSceneViewModelTest: XCTestCase {
    
    private var sut: ProductRegisterationSceneViewModel!
    private let scheduler = TestScheduler(initialClock: 0)
    private var disposeBag = DisposeBag()
    let apiURL = MarketAPIURL.productRegistration.url!
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
        let mockProductRepository = MarketProductRepository(service: mockAPIService)
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let mockRegisteredProductRepository = MarketRegisteredProductRepository(
            realm: try! Realm())
        
        let testUsecase = ProductRegisterationUsecase(
            productRepository: mockProductRepository,
            registredProductRepository: mockRegisteredProductRepository)
        
        self.sut = ProductRegisterationSceneViewModel(usecase: testUsecase)
    }

    override func tearDownWithError() throws {
        self.sut = nil
        self.disposeBag = DisposeBag()
    }

    func test_상품명만_입력하면_validationFailAlert이_output으로_오는지() throws {
        let expectation = XCTestExpectation(description: "validation Result comes out")
        
        let viewWillAppear = PublishSubject<Void>()
        let imagePickerCellDidSelected = PublishSubject<Int>()
        let imageDidSelected = PublishSubject<Data>()
        let productNameTextField = PublishSubject<String?>()
        let productPriceTextField = PublishSubject<String?>()
        let productDiscountedPriceTextField = PublishSubject<String?>()
        let productStockTextField = PublishSubject<String?>()
        let productDescritpionTextView = PublishSubject<String?>()
        let productCurrencySegmentedContorl = PublishSubject<Int>()
        let doneDidTapped = PublishSubject<Void>()
        let secret = PublishSubject<String>()
        
        let input = ProductRegisterationSceneViewModel.Input(
            viewWillAppear: viewWillAppear,
            imagePickerCellDidSelected: imagePickerCellDidSelected.asObservable(),
            imageDidSelected: imageDidSelected.asObservable(),
            productTitle: ControlProperty(values: productNameTextField, valueSink: productNameTextField),
            productCurrency: ControlProperty(values: productCurrencySegmentedContorl, valueSink: productCurrencySegmentedContorl),
            productPrice: ControlProperty(values: productPriceTextField, valueSink: productPriceTextField),
            prdouctDiscountedPrice: ControlProperty(values: productDiscountedPriceTextField, valueSink: productDiscountedPriceTextField),
            productStock: ControlProperty(values: productStockTextField, valueSink: productStockTextField),
            productDescriptionText: ControlProperty(values: productDescritpionTextView, valueSink: productDescritpionTextView),
            doneDidTapped: ControlEvent(events: doneDidTapped),
            didReceiveSecret: secret.asObservable())
        
        let output = sut.transform(input: input)
        
        let validationObserver = scheduler.createObserver(
            ProductRegisterationSceneViewModel.RegistrationFailureAlertViewModel.self)
        var alertTitle: String?
        
        output.validationFailureAlert
            .do(afterNext: { _ in
                expectation.fulfill() })
            .drive(onNext: { viewModel in
                alertTitle = viewModel.title })
            .disposed(by: disposeBag)

        self.scheduler.createColdObservable([(.next(3, "새로운 상품"))])
            .bind(to: productNameTextField)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([(.next(8, ()))])
            .bind(to: doneDidTapped)
            .disposed(by: disposeBag)
                    
        self.scheduler.start()
                    
        wait(for: [expectation], timeout: 20)
                    
        XCTAssertEqual(alertTitle, "대표사진, 가격, 재고, 상세정보는 필수 입력 항목이에요")
    
    }
    


}
