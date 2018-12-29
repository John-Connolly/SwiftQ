//
//  AsyncReliableQueue.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-26.
//

import Foundation
import NIO

public final class AsyncReliableQueue {

    let redis: AsyncRedis
    let bredis: AsyncRedis

    public init(redis: AsyncRedis, bredis: AsyncRedis) {
        self.redis = redis
        self.bredis = bredis
    }

    public func enqueue(task: Task) -> EventLoopFuture<RedisData> {
        let data = try! task.data() // FIX ME!!

        let redisData: [RedisData] = [
            RedisData.bulkString("LPUSH".data(using: .utf8)!),
            RedisData.bulkString("queue".data(using: .utf8)!),
            RedisData.bulkString(data),
            ]
        return redis.send(message: RedisData.array(redisData))
    }

    public func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]> {
        let redisData: [RedisData] = [
            RedisData.bulkString("LPUSH".data(using: .utf8)!),
            RedisData.bulkString("queue".data(using: .utf8)!),
        ]
        let data = tasks.map { RedisData.bulkString(try! $0.data()) }
        return redis.pipeLine(message: [RedisData.array(redisData + data)])
    }

    public func bdqueue() {
        let redisData: [RedisData] = [
            RedisData.bulkString("BRPOPLPUSH".data(using: .utf8)!),
            RedisData.bulkString("queue".data(using: .utf8)!),
            RedisData.bulkString("queue2".data(using: .utf8)!),
            RedisData.bulkString("0".data(using: .utf8)!),
            ]
        let resp = bredis.send(message: RedisData.array(redisData))
        resp.whenSuccess { data in
            switch data {
            case .bulkString(let data):
                let task = try! JSONDecoder().decode(Email.self, from: data)
                task.execute(loop: self.redis.eventLoop).whenComplete {
                    self.complete(task: data).whenComplete {
                        self.bdqueue()
                    }
                }
            default: ()
            }
//            print(data)

        }
    }

    public func complete(task: Data) -> EventLoopFuture<RedisData> {
        let redisData: [RedisData] = [
            RedisData.bulkString("LREM".data(using: .utf8)!),
            RedisData.bulkString("queue2".data(using: .utf8)!),
            RedisData.bulkString("0".data(using: .utf8)!),
            RedisData.bulkString(task),
            ]
        return redis.send(message: RedisData.array(redisData))
    }

    struct Email: Task {

        let email: String

        func execute(loop: EventLoop) -> EventLoopFuture<()> {
            return loop.newSucceededFuture(result: ())
        }

    }

}
