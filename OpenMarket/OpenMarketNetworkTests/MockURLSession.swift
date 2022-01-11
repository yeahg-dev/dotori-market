//
//  MockURLSession.swift
//  MockJSONParserTests
//
//  Created by 예거 on 2022/01/11.
//

import UIKit
@testable import OpenMarket

struct MockData {
    var data: Data {
        return NSDataAsset(name: "products")!.data
    }
}

struct MockURLSession: URLSessionProtocol {
    
    var makeRequestFail = false
    let sessionDataTask = MockURLSessionDataTask()
    
    init(makeRequestFail: Bool = false) {
        self.makeRequestFail = makeRequestFail
    }
    
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let successResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 200,
                                              httpVersion: "2",
                                              headerFields: nil)
        let failureResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 410,
                                              httpVersion: "2",
                                              headerFields: nil)
        sessionDataTask.resumeDidCall = {
            if self.makeRequestFail {
                completion(nil, failureResponse, nil)
            } else {
                completion(MockData().data, successResponse, nil)
            }
        }
        return sessionDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    
    var resumeDidCall: () -> Void = { }
    
    override func resume() {
        resumeDidCall()
    }
}
