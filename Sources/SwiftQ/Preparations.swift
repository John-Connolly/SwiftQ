//
//  Preparations.swift
//  SwiftQ
//
//  Created by John Connolly on 2019-01-02.
//

import Foundation
import NIO

public typealias Preparations = (Redis) -> EventLoopFuture<()>

public func onBoot(redis: Redis) -> EventLoopFuture<()> {
    let hostname = Host().name
    return redis.send(.sadd(key: RedisKey.processes, value: hostname)).map { _ in
        return ()
    }
}

public func consumerInfo(redis: Redis) -> EventLoopFuture<()> {
    let consumerInfo = ConsumerInfo.initial
    return redis.eventLoop.newFuture {
        try encode(item: consumerInfo)
    }.then { data in
        return redis.send(.set(key: Host().name, value: data)).map { value -> () in
            return ()
        }
    }

}
