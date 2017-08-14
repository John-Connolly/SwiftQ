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
    
    
    func zadd(_ boxedTask: Boxable) throws {
        try redisAdaptor.pipeline {
            let commands = [
                Command(command: "MULTI"),
                Command(command: "ZADD", args: [.string(RedisKey.scheduledQ.name),
                                                .string(boxedTask.time),
                                                .string(boxedTask.uuid)]),
                Command(command: "SET", args: [.string(boxedTask.uuid), .data(boxedTask.task)]),
                Command(command: "EXEC")
            ]
            return commands
        }
        
    }
    
    private func zrangeByScore() throws -> [Foundation.Data]? {
        let ids = try redisAdaptor.execute(Command(command: "ZRANGEBYSCORE", args:[
            .string(RedisKey.scheduledQ.name),
            .string("-inf"),
            .string(Date().unixTime.description)])).array
        return ids
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
                Command(command: "MULTI"),
                Command(command: "ZREM", args: zremArgs),
                Command(command: "LPUSH", args: lpushArgs),
                Command(command: "EXEC")
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
