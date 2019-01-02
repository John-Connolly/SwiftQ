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
        let data = encode(item: task)
        return send(.lpush(key: "queue", values: [data])).map { $0.int! }
    }

    public func enqueue<C: Codable>(contentsOf tasks: [C]) -> EventLoopFuture<Int> {
        return send(.lpush(key: "queue", values: tasks.map(encode))).map { $0.int! }
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

    private func send(_ commands: [Command]) -> EventLoopFuture<RedisData> {
       return redis.send(message: .array(commands.flatMap { $0.params2 }))
    }

    public func complete(task: Data) -> EventLoopFuture<[RedisData]> {
       return redis.pipeLine(message: [
            .array(Command.lrem(key: "queue2", count: 1, value: task).params2),
            .array(Command.incr(key: "stats:proccessed").params2),
            ])
    }

}

public protocol AsyncQueue {

    func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]>
    func blockingDequeue(_ f: @escaping (RedisData) -> ())
    func complete(task: Data) -> EventLoopFuture<RedisData>

}



// TODO: Return result here!
func encode<C: Codable>(item: C) -> Data {
    let encoder = JSONEncoder()
    if #available(OSX 10.13, *) {
        encoder.outputFormatting = .sortedKeys
    }
    return try! encoder.encode(item)
}
