//
//  ScheduledQueue.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation

final class ScheduledQueue: Monitorable {
    
    private let redisAdaptor: Adaptor
    
    private let queue: String
    
    init(config: RedisConfig, queue: String = "default") throws {
        self.queue = queue
        self.redisAdaptor = try RedisAdaptor(config: config, connections: 1)
    }
    
    func zadd(_ boxedTask: ZSettable) throws {
        try redisAdaptor.pipeline {
            return [
                .multi,
                .zadd(queue: RedisKey.scheduledQ.name, score: boxedTask.score, value: boxedTask.uuid),
                .set(key: boxedTask.uuid, value: boxedTask.task),
                .exec
            ]
        }
    }
    
    private func zrangeByScore() throws -> [Foundation.Data]? {
        let ids = try redisAdaptor.execute(.zrangebyscore(
            key: RedisKey.scheduledQ.name,
            min: "-inf",
            max: Date().unixTime.description)).array
        return ids
    }
    
    /// Pushs multiple tasks onto the work queue from the scheduled queue
    private func transferQ(tasks: [Foundation.Data]) throws {
        try redisAdaptor.pipeline {
            return [
                .multi,
                .zrem(key: RedisKey.scheduledQ.name, values: tasks),
                .lpush(key: RedisKey.workQ(queue).name, values: tasks),
                .exec
            ]
        }
    }
    
    
    func poll() {
        do {
            guard let data = try zrangeByScore() else {
                return
            }
            
            guard data.count > 0 else {
                return
            }
            
            try transferQ(tasks: data)
        } catch {
            Logger.log(error)
        }
    }
    
}
