//
//  ImageFile.swift
//  OpenMarket
//
//  Created by lily on 2022/01/07.
//

import UIKit

struct ImageFile {
    
    let fileName: String
    let image: UIImage
    let type: ImageType = .jpeg
    var data: Data? {
        switch self.type {
        case .jpg, .jpeg:
            guard let data = image.jpegData(compressionQuality: .zero) else {
                return nil
            }
            return data
        case .png:
            guard let data = image.pngData() else {
                return nil
            }
            return data
        }
    }
    
    enum ImageType: String {
        
        case jpg = ".jpg"
        case jpeg = ".jpeg"
        case png = ".png"
        
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
