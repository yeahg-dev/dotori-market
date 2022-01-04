//
//  MockJSONParser.swift
//  MockJSONParserTests
//
//  Created by 예거 on 2022/01/04.
//

import UIKit

enum MockJSONParser<T: Decodable> {
    
    static func decode(from jsonName: String) -> T? {
        guard let dataAsset = NSDataAsset(name: jsonName) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        decoder.dateDecodingStrategy = .iso8601
        
        let decodedData = try? decoder.decode(T.self, from: dataAsset.data)
        return decodedData
    }
}
