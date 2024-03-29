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
        completion: @escaping (Result<Data, Error>) -> Void)
    
    func executeURLRequest(
        of request: URLRequest,
        _ completion: @escaping (Result<Data, Error>) -> Void)
    
    func requestRx<T: APIRequest>(
        _ request: T)
    -> Observable<Data>
    
}
