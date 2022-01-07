//
//  Parserable.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/06.
//

import Foundation

protocol Parserable { }

extension Parserable {

    static func decode<T: Decodable>(from data: Data) -> T? {
        guard let data = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return data
    }
    
    static func encode<T: Encodable>(from data: T) -> Data? {
        guard let object = try? JSONEncoder().encode(data) else {
            return nil
        }
        return object
    }
}
