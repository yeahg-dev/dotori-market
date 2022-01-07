//
//  ImageFile.swift
//  OpenMarket
//
//  Created by lily on 2022/01/07.
//

import UIKit

struct ImageFile {
    
    let key: String
    let fileName: String
    let data: Data
    let type: ImageType
    
    enum ImageType {
        
        case jpg
        case jpeg
        case png
        
        var description: String {
            switch self {
            case .jpg:
                return "image/jpg"
            case .jpeg:
                return "image/jpeg"
            case .png:
                return "image/png"
            }
        }
    }
}
