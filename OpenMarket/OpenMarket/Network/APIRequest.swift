//
//  APIRequest.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

enum HTTPMethod: String {
    
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIRequest {
    
    static func requestHealthChecker() {
        guard let url = APIURL.healthChecker.url else { return }
        let request = URLRequest(url: url)
        execute(request: request, nil)
    }
    
    static func execute(request: URLRequest, _ completion: ((Result<Data, Error>) -> Void)?) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completion?(.failure(APIError.invalidResponseDate))
                      return
                  }
            
            guard let data = data else { return }
            completion?(.success(data))
        }
        dataTask.resume()
    }
}
