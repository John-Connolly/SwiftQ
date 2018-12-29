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
        return send(.lpush(key: "queue", values: [data]))
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
        }
    }

    private func sendb(_ command: Command) -> EventLoopFuture<RedisData> {
        return bredis.send(message: .array(command.params2))
    }

    private func send(_ command: Command) -> EventLoopFuture<RedisData> {
        return redis.send(message: .array(command.params2))
    }

    // TODO: maybe have an assert here
    public func blockingDequeue(_ f: @escaping (Data) -> ()) {
        let resp = sendb(.brpoplpush(q1: "queue", q2: "queue2", timeout: 0))
        resp.whenSuccess { data in
            f(data.data!)
            self.bdqueue()
        }
    }

    public func complete(task: Data) -> EventLoopFuture<RedisData> {
        return send(.lrem(key: "queue2", count: 0, value: task))
    }

    struct Email: Task {

        let email: String

        func execute(loop: EventLoop) -> EventLoopFuture<()> {
            return loop.newSucceededFuture(result: ())
        }

    }

}

public protocol AsyncQueue {

    func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]>
    func blockingDequeue(_ f: @escaping (RedisData) -> ())
    func complete(task: Data) -> EventLoopFuture<RedisData>

}
