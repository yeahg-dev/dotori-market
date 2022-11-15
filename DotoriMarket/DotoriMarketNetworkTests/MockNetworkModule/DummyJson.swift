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
        "id": 1,
        "vendor_id": 1,
        "name": "test",
        "description": "",
        "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/1/20221004/bd56d3d443bc11ed8b9b2de3d2728a0b_thumb.png",
        "currency": "KRW",
        "price": 0.0,
        "bargain_price": 0.0,
        "discounted_price": 0.0,
        "stock": 1,
        "created_at": "2022-10-04T00:00:00",
        "issued_at": "2022-10-04T00:00:00",
        "images": [
            {
                "id": 1,
                "url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/1/20221004/bd56d3d343bc11ed8b9bcd162d39eb8e_origin.png",
                "thumbnail_url": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/1/20221004/bd56d3d443bc11ed8b9b2de3d2728a0b_thumb.png",
                "issued_at": "2022-10-04T00:00:00"
            }
        ],
        "vendors": {
            "id": 1,
            "name": "soobak1234"
        }
    }
    """.data(using: .utf8)!
}
