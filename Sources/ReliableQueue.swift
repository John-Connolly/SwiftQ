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
    
    private let hostName = Host().name
    
    private let consumer: String?
    
    private let queue: String
    
    
    init(queue: String = "default",
         config: RedisConfig,
         consumer: String? = nil,
         concurrency: Int = 4) throws {
        self.queue = queue
        self.consumer = consumer
        self.redisAdaptor = try RedisAdaptor(config: config, connections: concurrency)
    }
    
    
    var processingQKey: String {
        return RedisKey.processingQ(consumerName).name
    }
    
    var consumerName: String {
        return consumer ?? hostName
    }
    
    
    /// Prepare is only called by consumers.  It adds the consumer name to a redis set.
    /// It also checks the processing queue for tasks and transfers them onto the work queue.
    func prepare() throws {
        let command = Command.sadd(key: "consumers", value: consumerName)
        try redisAdaptor.execute(command)
        
        let lrange = Command.lrange(key: processingQKey, start: 0, stop: -1)
        
        guard let items = try redisAdaptor.execute(lrange).array else {
            return
        }
        
        guard items.count > 0 else {
            return
        }
        
        try redisAdaptor.pipeline {
            return [
                .multi,
                .lpush(key: RedisKey.workQ(queue).name, values: items),
                .del(key: processingQKey),
                .exec
            ]
        }
        
    }
    
    /// Pushes a task onto the work queue
    func enqueue(item: EnqueueingBox) throws {
        try redisAdaptor.pipeline {
            return [
                .multi,
                .lpush(key: RedisKey.workQ(item.queue).name, values: [item.uuid]),
                .set(key: item.uuid, value: item.value),
                .exec
            ]
        }
    }
    
    /// Pushes and array of task onto the work queue
    func enqueue(contentsOf items: [EnqueueingBox]) throws {
        let ids = items.map { $0.uuid }
        try redisAdaptor.pipeline {
            return [
                .multi,
                .lpush(key: RedisKey.workQ(queue).name, values: ids),
                .mset(EnqueueingBoxes(items)),
                .exec
            ]
        }
    }
    
    /// Pops the last element off the work queue and pushes it to the front of the processsing queue
    /// Blocks indefinitely if there are no items in the queue
    func dequeue() throws -> Foundation.Data? {
        let command = Command.brpoplpush(q1: RedisKey.workQ(queue).name, q2: processingQKey, timeout: 0)
        return try redisAdaptor.execute(command).string
            .map { id in
                return .get(key: id)
            }.flatMap { command in
                return try redisAdaptor.execute(command).data
        }
    }
    
    /// Removes task from the processing queue, increments the stats key
    //  and deletes the task.
    func complete(item: EnqueueingBox, success: Bool) throws {
        let incrKey = success ? RedisKey.success(consumerName).name : RedisKey.failure(consumerName).name
        try redisAdaptor.pipeline {
            return [
                .multi,
                .lrem(key: processingQKey, count: 0, value: item.uuid),
                .incr(key: incrKey),
                .del(key: item.uuid),
                .exec
            ]
        }
    }
    
    /// Re-queues a periodic job in the zset
    func requeue(box: PeriodicBox, success: Bool) throws {
        let incrKey = success ? RedisKey.success(consumerName).name : RedisKey.failure(consumerName).name
        try redisAdaptor.pipeline {
            return [
                .lrem(key: processingQKey, count: 0, value: box.uuid),
                .incr(key: incrKey),
                .zadd(queue: RedisKey.scheduledQ.name, score: box.time, value: box.uuid)
            ]
        }
    }
    
    /// Pushes data into the log list
    func log(task: Task, error: Error) throws {
        let log = try task.createLog(with: error, consumer: consumerName)
        try redisAdaptor.pipeline {
            return  [
                .multi,
                .lrem(key: processingQKey, count: 0, value: task.uuid),
                .del(key: task.uuid),
                .incr(key: RedisKey.failure(consumerName).name),
                .lpush(key: RedisKey.log.name, values: [log]),
                .exec
            ]
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
