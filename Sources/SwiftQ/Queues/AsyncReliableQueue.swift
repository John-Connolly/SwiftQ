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
//    let key: RedisKey
    let name: String

    var dequeued: ((Data) -> ())?

    public init(redis: AsyncRedis, bredis: AsyncRedis) { //, name: String
        self.redis = redis
        self.bredis = bredis
        self.name = RedisKey.queue("default")
    }

    public func enqueue<C: Codable>(task: C) -> EventLoopFuture<Int> {
        let data = encode(item: task)
        return redis.send(.lpush(key: name, values: [data])).map { $0.int! }
    }

    public func enqueue<C: Codable>(contentsOf tasks: [C]) -> EventLoopFuture<Int> {
        return redis.send(.lpush(key: name, values: tasks.map(encode))).map { $0.int! }
    }

    public func bdqueue() {
        let resp = bredis.send(.brpoplpush(q1:name, q2: name + ":processing", timeout: 0))
        resp.whenSuccess { data in
              self.dequeued?(data.data!)
              self.bdqueue()
        }
    }

    public func enqueue<C: Codable>(task: C, at time: Time) -> EventLoopFuture<Int> {
        fatalError()
    }

    public func complete(task: Data) -> EventLoopFuture<[RedisData]> {
        return flatten(array: [
            redis.send(.lrem(key: name + ":processing", count: 1, value: task)),
            redis.send(.incr(key: "stats:proccessed"))
            ], on: redis.eventLoop)
    }

}

public protocol AsyncQueue {

    func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]>
    func blockingDequeue(_ f: @escaping (RedisData) -> ())
    func complete(task: Data) -> EventLoopFuture<RedisData>

}



// TODO: Return result here!
func encode<C: Encodable>(item: C) -> Data {
    let encoder = JSONEncoder()
    if #available(OSX 10.13, *) {
        encoder.outputFormatting = .sortedKeys
    }
    return try! encoder.encode(item)
}

func decode<C: Decodable>(data: Data) -> C {
    let decoder = JSONDecoder()
    return try! decoder.decode(C.self, from: data)
}
