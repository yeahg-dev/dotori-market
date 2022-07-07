//
//  MockMarketAPIService.swift
//  DotoriMarketViewModelTests
//
//  Created by 1 on 2022/07/06.
//

import Foundation
import RxSwift
@testable import DotoriMarket

struct MockMarketAPIService: APIServcie {
    
    var mockResponse: ResponseDataType?
    
    func request<T>(_ request: T, completion: @escaping (Result<T.Response, Error>) -> Void) where T : APIRequest {
        completion(.success(mockResponse as! T.Response))
    }
    
    func createURLRequest<T>(of APIRequest: T) -> URLRequest? where T : APIRequest {
        return nil
    }
    
    func executeURLRequest<T>(of request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        //
    }
    
    func requestRx<T>(_ request: T) -> Observable<T.Response> where T : APIRequest {
        return Observable.just(mockResponse as! T.Response)
    }
    
}
