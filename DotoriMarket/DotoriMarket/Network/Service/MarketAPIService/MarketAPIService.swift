//
//  APIExecutor.swift
//  DotoriMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation

import RxSwift

struct MarketAPIService: APIServcie {
    
    private let session: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    func requestRx<T: APIRequest>(
        _ request: T) -> Observable<T.Response> {
            let observable = Observable<T.Response>.create{ observer in
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
    
    func request<T: APIRequest>(
        _ request: T,
        completion: @escaping (Result<T.Response, Error>
        ) -> Void) {
        guard let urlRequest = request.urlRequest() else {
            completion(.failure(MarketAPIServiceError.URLRequestCreationFail))
            return
        }
        
        self.executeURLRequest(of: urlRequest, completion)
    }

    func executeURLRequest<T: Decodable>(
        of request: URLRequest,
        _ completion: @escaping (Result<T, Error>
        ) -> Void ) {
        let dataTask = session.dataTask(with: request) { data, response, error in
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
    
    enum MarketAPIServiceError: Error {
        
        case URLRequestCreationFail
        
    }
}
