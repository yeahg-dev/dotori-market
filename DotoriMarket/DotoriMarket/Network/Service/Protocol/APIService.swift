//
//  APIService.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/06.
//

import Foundation

import RxSwift

protocol APIServcie {
    
    func request<T: APIRequest>(
        _ request: T,
        completion: @escaping (Result<T.Response, Error>
        ) -> Void)
    
    func executeURLRequest<T: Decodable>(
        of request: URLRequest,
        _ completion: @escaping (Result<T, Error>
        ) -> Void )
    
    func requestRx<T: APIRequest>(
        _ request: T) -> Observable<T.Response>
}
