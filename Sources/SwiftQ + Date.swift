//
//  SwiftQ + Date.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-15.
//
//

import Foundation

extension Date {
    
    var unixTime: Int64 {
        return Int64(self.timeIntervalSince1970)
    }
    
}
