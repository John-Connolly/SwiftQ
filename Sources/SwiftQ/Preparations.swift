//
//  Preparations.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation
import NIO

public typealias Preparations = (AsyncRedis) -> EventLoopFuture<()>

public func onBoot(redis: AsyncRedis) -> EventLoopFuture<()> {
    let hostname = Host().name
    return redis.send(.sadd(key: RedisKey.processes, value: hostname)).map { _ in
        return ()
    }
}

public func consumerInfo(redis: AsyncRedis) -> EventLoopFuture<()> {
    let consumerInfo = ConsumerInfo.initial
    return redis.eventLoop.newFuture {
        try encode(item: consumerInfo)
    }.then { data in
        return redis.send(.set(key: Host().name, value: data)).map { value -> () in
            return ()
        }
    }

}


extension EventLoop {

    func newFuture<T>(from f: () throws -> T) -> EventLoopFuture<T> {
        do {
            return newSucceededFuture(result: try f())
        } catch {
            return newFailedFuture(error: error)
        }
    }

}
