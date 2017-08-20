//
//  SwiftQProducer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-05-26.
//
//

import Foundation

public final class SwiftQProducer {
    
    private let reliableQueue: ReliableQueue
    
    private let scheduledQueue: ScheduledQueue
    
    public init(redisConfig: RedisConfig) throws {
        self.reliableQueue = try ReliableQueue(config: redisConfig)
        self.scheduledQueue = try ScheduledQueue(config: redisConfig)
        
        if redisConfig.password == nil {
            Logger.warning("Insecure redis configuration, always set a password")
        }
    }
    
    /// Pushes a task onto the the tasks specific queue.  Unless specified
    /// this will be the default work queue.
    public func enqueue(task: Task) throws {
        try reliableQueue.enqueue(item: EnqueueingBox(task))
    }
    
    /// Pushes multiple tasks onto the default work queue only.
    public func enqueue(tasks: [Task]) throws {
        let boxes = try tasks.map(EnqueueingBox.init)
        try reliableQueue.enqueue(contentsOf: boxes)
    }
    
    /// Pushes a chained task onto the work queue
    public func enqueue(chain: Chain) throws {
        try reliableQueue.enqueue(item: EnqueueingBox(chain))
    }
    
    /// Pushes a task on the scheduled queue
    public func enqueue(task: Task, time: Time) throws {
        let box = try ScheduledBox(task, when: time)
        try scheduledQueue.zadd(box)
    }
    
    /// Pushes a task on the scheduled queue, after the task is completed it is pushed back
    /// onto the scheduled queue.
    public func enqueue(periodicTask: PeriodicTask) throws {
        let box = try PeriodicBox(periodicTask)
        try scheduledQueue.zadd(box)
    }
    
}


enum JSONKey: String {
    case taskName
    case identification
    case args
    case error
    case errorAt
    case consumer
    case chain
    case createdAt
    case uuid
}
