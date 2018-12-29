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

    var dequeued: ((Data) -> ())?

    public init(redis: AsyncRedis, bredis: AsyncRedis) {
        self.redis = redis
        self.bredis = bredis
    }

    public func enqueue<C: Codable>(task: C) -> EventLoopFuture<Int> {
        let encoder = JSONEncoder() // Fix this!
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }
        let data = try! encoder.encode(task)
        return send(.lpush(key: "queue", values: [data])).map { $0.int! }
    }

    public func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]> {
        let redisData: [RedisData] = [
            .bulkString("LPUSH".data(using: .utf8)!),
            .bulkString("queue".data(using: .utf8)!),
        ]
        let data = tasks.map { RedisData.bulkString(try! $0.data()) }
        return redis.pipeLine(message: [.array(redisData + data)])
    }

    public func bdqueue() {
        let resp = sendb(.brpoplpush(q1: "queue", q2: "queue2", timeout: 0))
        resp.whenSuccess { data in
              self.dequeued?(data.data!)
              self.bdqueue()
        }
    }

    private func sendb(_ command: Command) -> EventLoopFuture<RedisData> {
        return bredis.send(message: .array(command.params2))
    }

    private func send(_ command: Command) -> EventLoopFuture<RedisData> {
        return redis.send(message: .array(command.params2))
    }

    public func complete(task: Data) -> EventLoopFuture<RedisData> {
        return send(.lrem(key: "queue2", count: 0, value: task))
    }


}

public protocol AsyncQueue {

    func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]>
    func blockingDequeue(_ f: @escaping (RedisData) -> ())
    func complete(task: Data) -> EventLoopFuture<RedisData>

}
