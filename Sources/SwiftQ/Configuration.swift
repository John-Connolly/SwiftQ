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
    /// Max number of threads the worker will use also the max number of connections that will be
    /// created by the connection pool.  If set to 4, the worker will block on 4 different threads with
    /// 4 separate redis connections while its waiting for work.
    let concurrency: Int
    
    let redisConfig: RedisConfiguration
    
    let tasks: [Task.Type]
    /// Used in order to specify a custom queue to consume from
    let queue: String
    /// Used for consumer specific processing queues.
    /// If not provided the servers hostname will be used.
    let consumerName: String
    
    let middleware: [Middleware]
    
    public init(pollingInterval: Int,
         enableScheduling: Bool,
         concurrency: Int,
         redisConfig: RedisConfiguration,
         tasks: [Task.Type],
         queue: String = "default",
         consumerName: String? = nil,
         middleware: [Middleware] = []) {
        
        self.pollingInterval = pollingInterval
        self.enableScheduling = enableScheduling
        self.concurrency = concurrency
        self.redisConfig = redisConfig
        self.tasks = tasks
        self.queue = queue
        self.consumerName = consumerName ?? Host().name
        self.middleware = middleware
    }
    
}
