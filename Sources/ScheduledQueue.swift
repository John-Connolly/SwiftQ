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
        self.redisAdaptor = try RedisAdaptor(config: config)
    }
    
    
    func zadd(_ scheduledTask: ScheduledTask) throws {
        try redisAdaptor.execute(Command(command: "ZADD", args: [.string(RedisKey.scheduledQ.name),
                                                                 .string(scheduledTask.time),
                                                                 .data(scheduledTask.task)]))
    }
    
    
    private func zrangeByScore() throws -> [Foundation.Data]? {
        return try redisAdaptor.execute(Command(command: "ZRANGEBYSCORE", args:[.string(RedisKey.scheduledQ.name),
                                                                                 .string("-inf"),
                                                                                 .string(Date().unixTime.description)])).array
    }
    
    
    /// Pushs multiple tasks onto the work queue from the scheduled queue
    private func transferQ(tasks: [Foundation.Data]) throws {
        let data = tasks.map(ArgumentsType.data)
        var zremArgs = [ArgumentsType.string(RedisKey.scheduledQ.name)]
        zremArgs.append(contentsOf: data)
        var lpushArgs = [ArgumentsType.string(RedisKey.workQ(queue).name)]
        lpushArgs.append(contentsOf: data)
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "ZREM", args: zremArgs),
                Command(command: "LPUSH", args: lpushArgs)
            ]
            return commands
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
