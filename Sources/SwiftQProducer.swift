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
        let data = try task.serialized()
        try reliableQueue.lpush(task: data, queue: task.queue)
    }
    
    /// Pushes multiple tasks onto the default work queue only.
    public func enqueue(tasks: [Task]) throws {
        let tasks = try tasks.map { try $0.serialized() }
        try reliableQueue.lpush(tasks: tasks)
    }
    
    /// Pushes a chained task onto the work queue
    public func enqueue(chain: Chain) throws {
        let chainedTask = try chain.serialized()
        try reliableQueue.lpush(task: chainedTask)
    }
    
    /// Pushes a task on the scheduled queue
    public func enqueue(task: Task, time: Time) throws {
        let scheduledTask = try ScheduledTask(task, when: time)
        try scheduledQueue.zadd(scheduledTask)
    }
    
    /// Pushes a task on the scheduled queue, after the task is completed it is pushed back
    /// onto the scheduled queue.
    public func enqueue(periodicTask: PeriodicTask) throws {
        let scheduledTask = try ScheduledTask(periodicTask, when: periodicTask.frequency.nextTime)
        try scheduledQueue.zadd(scheduledTask)
    }
    
}


enum JSONKey: String {
    case taskName
    case identification
    case args
    case error
    case chain
}



