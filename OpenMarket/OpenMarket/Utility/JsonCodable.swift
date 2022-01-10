//
//  Parserable.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/06.
//

import UIKit

struct JsonCodable {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dateFormatter = DateFormatter()

    func decode<T: Decodable>(from data: Data) -> T? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        guard let data = try? decoder.decode(T.self, from: data) else {
            return nil
        }
        return data
    }
    
    func decode<T: Decodable>(from fileName: String) -> T? {
        guard let dataAsset = NSDataAsset(name: fileName) else {
            return nil
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let decodedData = try? decoder.decode(T.self, from: dataAsset.data)
        return decodedData
    }
    
    func encode<T: Encodable>(from data: T) -> Data? {
        guard let object = try? encoder.encode(data) else {
            return nil
        }
        return object
    }
}
