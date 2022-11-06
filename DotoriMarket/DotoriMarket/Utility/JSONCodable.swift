//
//  Parserable.swift
//  DotoriMarket
//
//  Created by 예거 on 2022/01/06.
//

import UIKit

struct JSONCodable {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dateFormatter = DateFormatter()

    func decode<T: Decodable>(from data: Data, dateFormat: DateFormat) -> T? {
        dateFormatter.dateFormat = dateFormat.formatString
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        do {
            let data = try decoder.decode(T.self, from: data)
            return data
        } catch {
            print("Error decoding with type :\(T.self), \(error.localizedDescription)")
        }
        return nil
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

enum DateFormat {
    
    case short
    case long
    
    var formatString: String {
        switch self {
        case .short:
            return "yyyy-MM-dd'T'HH:mm:ss"
        case .long:
            return "yyyy-MM-dd'T'HH:mm:ss.SS"
        }
    }
    
}
