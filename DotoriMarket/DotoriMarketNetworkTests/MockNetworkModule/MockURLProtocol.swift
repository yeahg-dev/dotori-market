//
//  MockURLProtocol.swift
//  DotoriMarketViewModelTests
//
//  Created by lily on 2022/07/07.
//

import Foundation

class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // URL Loading System으로부터 응답을 받아 client에게 전달
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
           fatalError("Handler is unavailable.")
         }
           
         do {
           let (response, data) = try handler(request)

           client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
           
           if let data = data {
             client?.urlProtocol(self, didLoad: data)
           }
           client?.urlProtocolDidFinishLoading(self)
         } catch {
           client?.urlProtocol(self, didFailWithError: error)
         }
    }
    
    override func stopLoading() {
        print("request가 취소되었습니다")
    }
}
