//
//  SwiftQ + Array.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-15.
//
//

import Foundation

extension Array {
    
    mutating func dequeue() -> Element? {
        guard let job = self.first else { return nil }
        self.removeFirst()
        return job
    }
    
    
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
    
}
