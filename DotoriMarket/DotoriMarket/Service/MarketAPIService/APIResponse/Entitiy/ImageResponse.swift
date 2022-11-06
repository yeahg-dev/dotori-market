//
//  ImageResponse.swift
//  DotoriMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct ImageResponse: Codable {
    
    let id: Int
    let url: String
    let thumbnailURL: String
    let issuedAt: String
    
    private enum CodingKeys: String, CodingKey {
        
        case thumbnailURL = "thumbnail_url"
        case issuedAt = "issued_at"
        case id, url
    }
}

extension ImageResponse {
    
    func toDomain() -> Image {
        return Image(id: self.id,
                     url: self.url,
                     thumbnailURL: self.thumbnailURL)
    }
}
