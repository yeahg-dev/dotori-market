//
//  ProductRegistrationSceneViewModelTest.swift
//  DotoriMarketViewModelTests
//
//  Created by lily on 2022/07/28.
//

import XCTest
@testable import DotoriMarket

import RxSwift
import RxCocoa
import RxTest
import RealmSwift

class ProductRegistrationSceneViewModelTest: XCTestCase {
    
    private var sut: ProductRegistrationSceneViewModel!
    private var sutInput: ProductRegistrationSceneViewModel.Input!
    private let scheduler = TestScheduler(initialClock: 0)
    private var disposeBag = DisposeBag()
    let apiURL = MarketAPIURL.productRegistration.url!
    
    // 테스트 이벤트를 받을 수 있는 Subject 정의
    private var viewWillAppear = BehaviorSubject<Void>(value: ())
    private var imagePickerCellDidSelected = PublishSubject<Int>()
    private var imageDidSelected = BehaviorSubject<Data>(value: Data())
    private var productNameTextField = BehaviorSubject<String?>(value: nil)
    private var productPriceTextField = BehaviorSubject<String?>(value: nil)
    private var productDiscountedPriceTextField = BehaviorSubject<String?>(value: nil)
    private var productStockTextField = BehaviorSubject<String?>(value: nil)
    private var productDescritpionTextView = BehaviorSubject<String?>(value: "")
    private var productCurrencySegmentedContorl = BehaviorSubject(value: 0)
    private var doneDidTapped = PublishSubject<Void>()
    private var secret = PublishSubject<String>()
  
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
        
        let mockUsecase = ProductRegistrationUsecase(
            productRepository: mockProductRepository,
            registredProductRepository: mockRegisteredProductRepository)
        
        self.sut = ProductRegistrationSceneViewModel(usecase: mockUsecase)
        self.sutInput = ProductRegistrationSceneViewModel.Input(
            viewWillAppear: self.viewWillAppear,
            imagePickerCellDidSelected: self.imagePickerCellDidSelected.asObservable(),
            imageDidSelected: self.imageDidSelected.asObservable(),
            productTitle: ControlProperty(
                values: self.productNameTextField,
                valueSink: self.productNameTextField),
            productCurrency: ControlProperty(
                values: self.productCurrencySegmentedContorl,
                valueSink: self.productCurrencySegmentedContorl),
            productPrice: ControlProperty(
                values: self.productPriceTextField,
                valueSink: self.productPriceTextField),
            prdouctDiscountedPrice: ControlProperty(
                values: self.productDiscountedPriceTextField,
                valueSink: self.productDiscountedPriceTextField),
            productStock: ControlProperty(
                values: self.productStockTextField,
                valueSink: self.productStockTextField),
            productDescriptionText: ControlProperty(
                values: self.productDescritpionTextView,
                valueSink: self.productDescritpionTextView),
            doneDidTapped: ControlEvent(events: self.doneDidTapped),
            didReceiveSecret: self.secret.asObservable())
        
    }

    override func tearDownWithError() throws {
        self.sut = nil
        self.disposeBag = DisposeBag()
        self.viewWillAppear = BehaviorSubject<Void>(value: ())
        self.imagePickerCellDidSelected = PublishSubject<Int>()
        self.imageDidSelected = BehaviorSubject<Data>(value: Data())
        self.productNameTextField = BehaviorSubject<String?>(value: "")
        self.productPriceTextField = BehaviorSubject<String?>(value: "")
        self.productDiscountedPriceTextField = BehaviorSubject<String?>(value: "")
        self.productStockTextField = BehaviorSubject<String?>(value: "")
        self.productDescritpionTextView = BehaviorSubject<String?>(value: "")
        self.productCurrencySegmentedContorl = BehaviorSubject(value: 0)
        self.doneDidTapped = PublishSubject<Void>()
        self.secret = PublishSubject<String>()
    }

    func test_상품명만_입력하면_validationFailAlert이_output으로_오는지() throws {
        // 테스트 이벤트 생성
        self.scheduler.createColdObservable([(.next(1, "새로운 상품"))])
            .bind(to: self.productNameTextField)
            .disposed(by: disposeBag)
        
        self.scheduler.createColdObservable([(.next(3, ()))])
            .subscribe(self.doneDidTapped)
            .disposed(by: disposeBag)
        
        // 테스트 이벤트에 대한 Output을 관찰할 observer 정의
        let observer = self.scheduler.createObserver(String?.self)
        
        let output = sut.transform(input: sutInput)
        
        // Output을 observer에 바인딩
        output.validationFailureAlert
            .asObservable()
            .map({ viewModel in
                viewModel.title })
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
                    
        XCTAssertEqual(observer.events,
                       [(.next(3, "가격, 재고, 상세정보는 필수 입력 항목이에요"))])
    
    }

    func test_imagePicketCell을_선택하면_ImagePicker가_뜨는지() throws {
        self.scheduler.createColdObservable([(.next(3, 0))])
            .bind(to: imagePickerCellDidSelected)
            .disposed(by: disposeBag)
        
        let observer = self.scheduler.createObserver(Bool.self)
        
        let output = sut.transform(input: sutInput)
        
        output.presentImagePicker
            .asObservable()
            .map{ _ in true }
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        self.scheduler.start()
                    
        XCTAssertEqual(observer.events,
                       [(.next(3, true))])
        
    }
    
}
