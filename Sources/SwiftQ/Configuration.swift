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
    /// If not provided the servers hostname will be used.
    let consumerName: String?

    let preparations: [Preparations]

    let repeatedTasks: [RepeatedTasks]
    
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
        self.preparations = [
            onBoot,
            consumerInfo
        ]

        self.repeatedTasks = [
            heartBeat,
        ]
    }
    
}
