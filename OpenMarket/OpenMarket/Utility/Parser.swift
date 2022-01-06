//
//  Parser.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/06.
//

import Foundation

struct Parser {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    func decode<T: Decodable>(from data: Data) -> T? {
        guard let data = try? decoder.decode(T.self, from: data) else {
            return nil
        }
        return data
    }
    
    func encode<T: Encodable>(from data: T) -> Data? {
        guard let object = try? encoder.encode(data) else {
            return nil
        }
        return object
    }
}
