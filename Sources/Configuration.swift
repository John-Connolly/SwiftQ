//
//  WorkerConfiguration.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-15.
//
//

import Foundation

public struct Configuration {
    
    /// milliseconds
    let pollingInterval: Int
    /// If not using Scheduled tasks its more performant to set to false
    let enableScheduling: Bool
    
    let concurrency: Int
    
    let redisConfig: RedisConfig
    
    let tasks: [Task.Type]
    /// Used in order to specify a custom queue to consume from
    let queue: String
    /// Used for consumer specific processing queues.
    /// If not provided Host.current().name will be used
    let consumerName: String?
    
    public init(pollingInterval: Int,
         enableScheduling: Bool,
         concurrency: Int,
         redisConfig: RedisConfig,
         tasks: [Task.Type],
         queue: String = "default",
         consumerName: String? = nil) {
        
        self.pollingInterval = pollingInterval
        self.enableScheduling = enableScheduling
        self.concurrency = concurrency
        self.redisConfig = redisConfig
        self.tasks = tasks
        self.queue = queue
        self.consumerName = consumerName
        
    }
    
}


public struct RedisConfig {
    
    let redisDB: Int?
    
    let hostname: String
    
    let port: UInt16
    
    let password: String?
    
    public static var development: RedisConfig {
        return .init(redisDB: nil, hostname: "127.0.0.1", port: 6379, password: nil)
    }
    
    public init(redisDB: Int?, hostname: String, port: UInt16, password: String?) {
        self.redisDB = redisDB
        self.hostname = hostname
        self.port = port
        self.password = password
    }
    
}
