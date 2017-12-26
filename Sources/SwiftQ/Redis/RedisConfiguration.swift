//
//  RedisConfiguration.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-10-12.
//

import Foundation

public struct RedisConfiguration {
    
    let redisDB: Int?
    
    let hostname: String
    
    let port: UInt16
    
    let password: String?
    
    public static var development: RedisConfiguration {
        return .init(redisDB: nil, hostname: "127.0.0.1", port: 6379, password: nil)
    }
    
    public init(redisDB: Int?, hostname: String, port: UInt16, password: String?) {
        self.redisDB = redisDB
        self.hostname = hostname
        self.port = port
        self.password = password
    }
    
}
