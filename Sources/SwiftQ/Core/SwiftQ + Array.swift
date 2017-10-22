//
//  SwiftQ + Array.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-15.
//
//

import Foundation

extension Array {
    
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
    
    func prepend(_ element: Element) -> [Element] {
        var array = self
        array.insert(element, at: 0)
        return array
    }
    
}
