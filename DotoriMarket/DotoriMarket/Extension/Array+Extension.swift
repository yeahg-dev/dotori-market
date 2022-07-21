//
//  Array+Extension.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/18.
//

import UIKit

extension Array {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        
        switch indices.contains(index) {
        case true:
            return self[index]
        case false:
            return nil
        }
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
}

extension Array where Element == Data {
    
    func imageFile(fileName: String) -> [ImageFile?] {
        
        var imageFileNo = 0
        let imageFiles = self.map { data -> ImageFile? in
            imageFileNo += 1
            if let image = UIImage(data: data) {
                return ImageFile(fileName:  "\(fileName)-\(imageFileNo)", image: image)
            } else {
                return nil
            }
        }
        return imageFiles
    }
}
