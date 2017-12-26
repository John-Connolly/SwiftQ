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
    
    

    
//    private let clientFuture: Future<RedisClient>
//    
//    private let eventLoop: EventLoop
    
    public init(on queue: DispatchQueue) throws {
//        self.clientFuture = try RedisClient.connect(on: queue)
//        self.eventLoop = queue
    }
    
    
//    public func enqueue(task: Task) throws -> Future<[RedisData]>  {
//        let pipeline = client.makePipeline()
//        try pipeline.enqueue(command: "MULTI")
//        try pipeline.enqueue(command: "LPUSH", arguments: [RedisData(bulk: "myList"),RedisData(bulk: task.uuid)])
//        let data = try task.data()
//        let string = String(data: data, encoding: .utf8)!
//        try pipeline.enqueue(command: "SET", arguments: [RedisData(bulk: task.uuid), RedisData(bulk: string)])
//        try pipeline.enqueue(command: "EXEC")
//        return try pipeline.execute()
//    }
    
    public func enqueue(tasks: [Task]) throws -> Future<[RedisData]>? {
        
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
        
        return nil
    }
    
    
    
    
}
