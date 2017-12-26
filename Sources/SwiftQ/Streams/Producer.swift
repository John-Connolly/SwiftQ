//
//  Producer.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-12-03.
//

import Foundation
import Redis
import Async

public final class Producer {
    
    private let client: RedisClient
    
    public init(on queue: EventLoop) throws {
        self.client = try RedisClient.connect(on: queue)
    }
    
    public func enqueue(_ task: Task) throws -> Future<Void>  {
//        let pipeline = client.makePipeline()
//        try pipeline.enqueue(command: "MULTI")
//        try pipeline.enqueue(command: "LPUSH", arguments: [RedisData(bulk: "myList"),RedisData(bulk: task.uuid)])
//        let data = try task.data()
//        let string = String(data: data, encoding: .utf8)!
//        try pipeline.enqueue(command: "SET", arguments: [RedisData(bulk: task.uuid), RedisData(bulk: string)])
//        try pipeline.enqueue(command: "EXEC")
//        return try pipeline.execute()
        
        let data = RedisData.bulkString(try task.data())
        return client.set(data, forKey: task.uuid)
    }
    
    public func enqueue(contentsOf tasks: [Task]) throws -> Future<Void> {
        
//        let promise = Promise<[RedisData]>()
        
//        let pipe = clientFuture.flatMap { client -> Future<RedisPipeline> in
//            let promise = Promise<RedisPipeline>()
//            promise.complete(client.makePipeline())
//            return promise.future
//        }
//
//        return pipe.flatMap { pipeline -> Future<[RedisData]> in
//            try! pipeline.enqueue(command: "MULTI")
//
//            var args: [RedisData] = [RedisData(bulk: "myList")]
//            let ids = tasks.map { RedisData(bulk: $0.uuid) }
//            args.append(contentsOf: ids)
//            try! pipeline.enqueue(command: "LPUSH", arguments: args)
//
//            try! pipeline.enqueue(command: "EXEC")
//
//            return try! pipeline.execute()
//        }
        
//        eventLoop.queue.async {
//            let pipeline = self.client.makePipeline()
//            try? pipeline.enqueue(command: "MULTI")
//
//            var args: [RedisData] = [RedisData(bulk: "myList")]
//            let ids = tasks.map { RedisData(bulk: $0.uuid) }
//            args.append(contentsOf: ids)
//            try? pipeline.enqueue(command: "LPUSH", arguments: args)
//
//            try? pipeline.enqueue(command: "EXEC")
//            try? pipeline.execute().do { data in
//                promise.complete(data)
//                }.catch { error in
//                print(error)
//                }
//        }
//        return promise.future
        
        return .done
    }

    
}
