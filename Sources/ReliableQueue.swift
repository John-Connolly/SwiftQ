//
//  ReliableQueue.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-07.
//
//

import Foundation

final class ReliableQueue {
    
    private let redisAdaptor: Adaptor
    
    private let blockingRedisAdaptor: Adaptor // Maybe have a pool here instead
    
    private let host = Host.current().name ?? ""
    
    private let consumer: String?
    
    private let queue: String
    
    
    init(queue: String = "default", config: RedisConfig, consumer: String? = nil) throws {
        self.queue = queue
        self.consumer = consumer
        self.redisAdaptor = try RedisAdaptor(config: config)
        self.blockingRedisAdaptor = try RedisAdaptor(config: config)
    }
    
    
    var processingQKey: String {
        let name = consumer ?? host
        return RedisKey.processingQ(name).name
    }
    
    
    /// Prepare is only called by consumers.  It adds the consumer name to a redis set.
    /// It also checks the processing queue for tasks and transfers them onto the work queue.
    func prepare() throws {
        let command = Command(command: "SADD", args: [.string("consumers"), .string(host)])
        try redisAdaptor.execute(command)
        
        let lrange = Command(command: "LRANGE", args: [.string(processingQKey), .string("0"), .string("-1")])
        
        guard let items = try redisAdaptor.execute(lrange).array else {
            return
        }
        
        guard items.count > 0 else {
            return
        }
        
        let tasks = items.map(ArgumentsType.data)
        var lremArgs: [ArgumentsType] = [.string(processingQKey),.string("0")]
        lremArgs.append(contentsOf: tasks)
        var lpushArgs: [ArgumentsType] = [.string(RedisKey.workQ(queue).name)]
        lpushArgs.append(contentsOf: tasks)
        
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: lremArgs),
                Command(command: "LPUSH", args: lpushArgs)
            ]
            return commands
        }
    }
    
    
    /// Pushs a task onto the work queue
    func lpush(task: Foundation.Data, queue: String = "default") throws {
        let command = Command(command: "LPUSH", args: [.string(RedisKey.workQ(queue).name), .data(task)])
        try redisAdaptor.execute(command)
    }
    
    
    /// Pushs multiple tasks onto the work queue
    func lpush(tasks: [Foundation.Data]) throws {
        var args = tasks.map { ArgumentsType.data($0) }
        args.insert(.string(RedisKey.workQ(queue).name), at: 0)
        try redisAdaptor.execute(Command(command: "LPUSH", args: args))
    }
    
    
    /// Pops the last element off the work queue and pushes it to the front of the processsing queue
    /// Blocks indefinitely if there are no items in the queue
    func brpoplpush() throws -> Foundation.Data? {
        let command = Command(command: "BRPOPLPUSH", args:[
            .string(RedisKey.workQ(queue).name),
            .string(processingQKey),
            .string("0")])
        return try blockingRedisAdaptor.execute(command).data
    }
    
    
    /// Removes a specific message off the processing queue and increments the correct stats key
    func finished(task: Foundation.Data, success: Bool) throws {
        let incrKey = success ? RedisKey.success(host).name : RedisKey.failure(host).name
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey), .string("0"), .data(task)]),
                Command(command: "INCR", args: [.string(incrKey) ])
            ]
            return commands
        }
    }
    
    
    func finished(periodicTask: ScheduledTask, success: Bool) throws {
        let incrKey = success ? RedisKey.success(host).name : RedisKey.failure(host).name
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey),
                                                .string("0"),
                                                .data(periodicTask.task)]),
                Command(command: "INCR", args: [.string(incrKey)]),
                Command(command: "ZADD", args: [.string(RedisKey.scheduledQ.name),
                                                .string(periodicTask.time),
                                                .data(periodicTask.task)])
            ]
            return commands
        }
    }
    
    
    /// Pushes data into the log list
    func log(task: Foundation.Data, log: Foundation.Data) throws {
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey), .string("0"), .data(task)]),
                Command(command: "INCR", args: [.string(RedisKey.failure(host).name)]),
                Command(command: "LPUSH", args: [.string(RedisKey.log(queue).name),.data(log)])
            ]
            return commands
        }
    }
    
}
