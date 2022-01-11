//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let jsonParser = JSONCodable()
        
        let request = HealthCheckerRequest()
        APIExecutor().execute(request) { result in
            switch result {
            case .success(let data):
                let stringedData = String(data: data, encoding: .utf8)!
                print("💚 헬스체크 : \(stringedData)💚")
            case .failure:
                print("❌ 헬스체크 : error❌")
            }
        }

        let request2 = ProductsListPageRequest(pageNo: 1, itemsPerPage: 10)
        APIExecutor().execute(request2) { result in
            switch result {
            case .success(let data):
                let decodedData: ProductsListPage! = jsonParser.decode(from: data)
                print("🧡 상품 리스트 조회 : \(decodedData.pages[0].name)🧡")
            case .failure:
                print("❌ 상품 리스트 조회 : error❌")
            }
        }
        
    }


}

