//
//  ReliableQueue.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-06-07.
//
//

import Foundation
import Dispatch

final class ReliableQueue {
    
    private let redisAdaptor: Adaptor
    
    private let blockingRedisAdaptor: Adaptor // Maybe have a pool here instead
    
    private let ipAddress = IPAddress().address
    
    private let consumer: String?
    
    private let queue: String
    
    
    init(queue: String = "default", config: RedisConfig, consumer: String? = nil) throws {
        self.queue = queue
        self.consumer = consumer
        self.redisAdaptor = try RedisAdaptor(config: config)
        self.blockingRedisAdaptor = try RedisAdaptor(config: config)
    }
    
    
    var processingQKey: String {
        return RedisKey.processingQ(consumerName).name
    }
    
    var consumerName: String {
        return consumer ?? ipAddress
    }
    
    
    /// Prepare is only called by consumers.  It adds the consumer name to a redis set.
    /// It also checks the processing queue for tasks and transfers them onto the work queue.
    func prepare() throws {
        let command = Command(command: "SADD", args: [.string("consumers"), .string(consumerName)])
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
    
    /// Pushes a task onto the work queue
    func enqueue(item: EnqueueingBox) throws {
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "MULTI"),
                Command(command: "LPUSH", args: [.string(RedisKey.workQ(item.queue).name), .string(item.uuid)]),
                Command(command: "SET", args: [.string(item.uuid), .data(item.value)]),
                Command(command: "EXEC")
            ]
            return commands
        }
    }
    
    /// Pushes and array of task onto the work queue
    func enqueue(contentsOf items: [EnqueueingBox]) throws {
        var listArgs = items.map { ArgumentsType.string($0.uuid) }
        listArgs.insert(.string(RedisKey.workQ(queue).name), at: 0)
        
        let setArgs = items.reduce([], { (args, item) -> [ArgumentsType] in
            var args = args
            args.append(contentsOf: [ArgumentsType.string(item.uuid), ArgumentsType.data(item.value)])
            return args
        })
        
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "MULTI"),
                Command(command: "LPUSH", args: listArgs),
                Command(command: "MSET", args: setArgs),
                Command(command: "EXEC")
            ]
            return commands
        }
    }
    
    /// Pops the last element off the work queue and pushes it to the front of the processsing queue
    /// Blocks indefinitely if there are no items in the queue
    func dequeue() throws -> Foundation.Data? {
        let dequeueCommand = Command(command: "BRPOPLPUSH", args:[
            .string(RedisKey.workQ(queue).name),
            .string(processingQKey),
            .string("0")])
        return try blockingRedisAdaptor.execute(dequeueCommand).string
            .map { id in
                return Command(command: "GET", args:[.string(id)])
            }.flatMap { command in
                return try blockingRedisAdaptor.execute(command).data
        }
    }
    
    /// Removes task from the processing queue, increments the stats key
    //  and deletes the task.
    func complete(item: EnqueueingBox, success: Bool) throws {
        let incrKey = success ? RedisKey.success(consumerName).name : RedisKey.failure(consumerName).name
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey), .string("0"), .string(item.uuid)]),
                Command(command: "INCR", args: [.string(incrKey) ]),
                Command(command: "DEL", args: [.string(item.uuid)])
            ]
            return commands
        }
    }
    
    /// Re-queues a periodic job in the zset
    func finished(box: PeriodicBox, success: Bool) throws {
        let incrKey = success ? RedisKey.success(consumerName).name : RedisKey.failure(consumerName).name
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey),
                                                .string("0"),
                                                .data(box.task)]),
                Command(command: "INCR", args: [.string(incrKey)]),
                Command(command: "ZADD", args: [.string(RedisKey.scheduledQ.name),
                                                .string(box.time),
                                                .data(box.task)])
            ]
            return commands
        }
    }
    
    /// Pushes data into the log list
    func log(task: Task, error: Error) throws {
        let log = try task.createLog(with: error)
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "LREM", args: [.string(processingQKey), .string("0"), .string(task.id.uuid)]),
                Command(command: "INCR", args: [.string(RedisKey.failure(consumerName).name)]),
                Command(command: "LPUSH", args: [.string(RedisKey.log(queue).name),.data(log)])
            ]
            return commands
        }
    }
    
}

extension ReliableQueue: Queue { }

protocol Queue {
    
    associatedtype Item
    
    associatedtype Result
    
    func enqueue(item: Item) throws
    
    func dequeue() throws -> Result?
    
    func complete(item: Item, success: Bool) throws
    
}
