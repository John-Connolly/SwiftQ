//
//  Logger.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-25.
//
//

import Foundation

struct Logger {
    
    static func time(function: () throws -> ()) rethrows {
        let date = Date()
        try function()
        let difference = Date().timeIntervalSince(date)
        print(difference)
    }
}
