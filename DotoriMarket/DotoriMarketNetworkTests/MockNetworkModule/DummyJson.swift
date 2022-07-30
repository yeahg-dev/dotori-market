//
//  DummyJson.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/30.
//

import Foundation

enum DummyJson {

    static let productDetailResponse: Data = """
    {
        "id": 522,
        "vendor_id": 6,
        "name": "아이폰13",
        "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/thumb/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
        "currency": "KRW",
        "price": 1300000,
        "description": "비싸",
        "bargain_price": 1300000,
        "discounted_price": 0,
        "stock": 12,
        "created_at": "2022-01-18T00:00:00.00",
        "issued_at": "2022-01-18T00:00:00.00",
        "images": [
          {
            "id": 352,
            "url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/origin/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
            "thumbnail_url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/6/thumb/f9aa6e0d787711ecabfa3f1efeb4842b.jpg",
            "succeed": true,
            "issued_at": "2022-01-18T00:00:00.00"
          }
        ],
        "vendors": {
          "name": "제인",
          "id": 6,
          "created_at": "2022-01-10T00:00:00.00",
          "issued_at": "2022-01-10T00:00:00.00"
        }
      }
    """.data(using: .utf8)!
}
