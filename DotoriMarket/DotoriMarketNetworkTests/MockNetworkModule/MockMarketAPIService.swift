//
//  MockMarketAPIService.swift
//  DotoriMarketViewModelTests
//
//  Created by lily on 2022/07/06.
//

import Foundation

import RxSwift
@testable import DotoriMarket

struct MockMarketAPIService: APIServcie {
  
    var mockResponse: Data
    
    init(mockResponse: Data) {
        self.mockResponse = mockResponse
    }
    
    func request<T>(_ request: T, completion: @escaping (Result<Data, Error>) -> Void) where T : APIRequest {
        completion(.success(mockResponse))
    }
    
    func requestRx<T>(_ request: T) -> Observable<Data> where T : APIRequest {
        return Observable.just(mockResponse)
    }
    
    func executeURLRequest(of request: URLRequest, _ completion: @escaping (Result<Data, Error>) -> Void) {
        //
    }
    
    
    
}
