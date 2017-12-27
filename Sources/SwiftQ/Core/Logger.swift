//
//  Logger.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-25.
//
//

import Foundation

struct Logger {
    
    enum LogLevel {
        case info
        case warning
        case fatal
    }
    
    static func time(function: () throws -> ()) rethrows {
        let date = Date()
        try function()
        let difference = Date().timeIntervalSince(date)
        print(difference)
    }
    
    static func log(_ item: Any,
                    level: LogLevel = .info,
                    functionName: String = #function,
                    fileName: String = #file) {
        
        switch level {
        case .info: print("[swiftQ] info:", item)
        case .warning:  print("[swiftQ] warning:", item, functionName, fileName)
        case .fatal:  print("[swiftQ] fatal:", item, functionName, fileName)
        }
        
    }
    
}
