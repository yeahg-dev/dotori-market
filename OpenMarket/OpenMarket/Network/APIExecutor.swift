//
//  APIExecutor.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation

protocol URLSessionProtocol { }

extension URLSession: URLSessionProtocol { }

struct APIExecutor {
    
    typealias Handler = (Result<Data, Error>) -> Void
    
    let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func execute(_ request: APIRequest, completion: Handler?) {
        guard let url = request.url else { return }
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = request.httpMethod.rawValue

        request.header.forEach { (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        urlRequest.httpBody = request.body

        executeTask(request: urlRequest, completion)
    }
    
    private func executeTask(request: URLRequest, _ completion: Handler?) {
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
