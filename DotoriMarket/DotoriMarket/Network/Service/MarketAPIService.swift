//
//  APIExecutor.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation
import RxSwift

struct MarketAPIService {
    
    func request<T: APIRequest>(
        _ request: T,
        completion: @escaping (Result<T.Response, Error>
        ) -> Void) {
        guard let urlRequest = self.createURLRequest(of: request) else {
            return
        }

        executeURLRequest(of: urlRequest, completion)
    }
    
    private func createURLRequest<T: APIRequest>(of APIRequest: T) -> URLRequest? {
        
        guard let url = APIRequest.url else { return nil}
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = APIRequest.httpMethod.rawValue

        APIRequest.header.forEach { (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        urlRequest.httpBody = APIRequest.body
        
        return urlRequest
    }
    
    private func executeURLRequest<T: Decodable>(
        of request: URLRequest,
        _ completion: @escaping (Result<T, Error>
        ) -> Void ) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completion(.failure(APIError.invalidResponseDate))
                      return
                  }
            
            guard let data = data else { return }
            guard let decoded: T = JSONCodable().decode(from: data) else {
                return
            }
            completion(.success(decoded))
        }
        dataTask.resume()
    }
}

extension MarketAPIService {
    
    func requestRx<T: APIRequest>(
        _ request: T) -> Observable<T.Response> {
            let observable = Observable<T.Response>.create { observer in
                self.request(request) { result in
                    switch result {
                    case.success(let response):
                        observer.onNext(response)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
                return Disposables.create()
            }
            return observable
        }
}
