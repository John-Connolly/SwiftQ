//
//  SwiftQ + Date.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-15.
//
//

import Foundation

extension Date {
    
    var unixTime: Int {
        return Int(self.timeIntervalSince1970)
    }
    
}
