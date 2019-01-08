//
//  RedisQueue.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-26.
//

import Foundation
import NIO

public final class RedisQueue {

    let redis: Redis
    let bredis: Redis
    let name: String

    var dequeued: ((Data) -> ())?

    public init(redis: Redis, bredis: Redis) { //, name: String
        self.redis = redis
        self.bredis = bredis
        self.name = RedisKey.queue("default")
    }

    public func enqueue<C: Codable>(task: C) -> EventLoopFuture<Int> {
        return redis.eventLoop.newFuture {
            try encode(item: task)
        }.then { data in
            return self.redis
                .send(.lpush(key: self.name, values: [data]))
                .thenThrowing { data in
                    try data.int.or(throw: SwiftQError.invalidType("Expected integer"))
            }
        }
    }

    public func enqueue<C: Codable>(contentsOf tasks: [C]) -> EventLoopFuture<Int> {
        return redis.eventLoop.newFuture {
            try tasks.map(encode)
        }.then { data -> EventLoopFuture<Int> in
            return self.redis
                .send(.lpush(key: self.name, values: data))
                .thenThrowing { data -> Int in
                    return try data.int.or(throw: SwiftQError.invalidType("Expected integer"))
            }
        }
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

    public func complete(task: Data) -> EventLoopFuture<RedisData> {
        return redis.send(.lrem(key: name + ":processing", count: 1, value: task))
    }

    public func recordStats(isSuccessful: Bool) -> EventLoopFuture<[RedisData]> {
        let commands: [Command] = [
            .incr(key: isSuccessful ? RedisKey.statsProcessed : RedisKey.statsFailed),
            .incr(key: isSuccessful ? RedisKey.statsProcessedDate(date()) : RedisKey.statsFailedDate(date())),
        ]
        return redis.pipeLine(commands)
    }

}

public protocol AsyncQueue {

    func enqueue(contentsOf tasks: [Task]) -> EventLoopFuture<[RedisData]>
    func blockingDequeue(_ f: @escaping (RedisData) -> ())
    func complete(task: Data) -> EventLoopFuture<RedisData>

}


func date() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateStyle = .short
    return formatter.string(from: date)
}

func encode<C: Encodable>(item: C) throws -> Data {
    let encoder = JSONEncoder()
    if #available(OSX 10.13, *) {
        encoder.outputFormatting = .sortedKeys
    }
    return try encoder.encode(item)
}

func decode<C: Decodable>(data: Data) throws -> C {
    let decoder = JSONDecoder()
    return try decoder.decode(C.self, from: data)
}
