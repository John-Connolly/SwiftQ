//
//  Command.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-09-06.
//
//

import Foundation
import Redis

enum Command {

    // transactions
    case multi
    case exec

    // connection
    case select(db: Int)

    // list
    case lrem(key: String, count: Int, value: String)
    case lpush(key: String, values: [String])
    case lrange(key: String, start: Int, stop: Int)
    case brpoplpush(q1: String, q2: String, timeout: Int)

    // keys
    case get(key: String)
    case del(key: String)
    case set(key: String, value: Data)
    //    case mset(EnqueueingBoxes) FIXME
    case incr(key: String)

    // sorted set
    case zadd(queue: String, score: String, value: String)
    case zrangebyscore(key: String, min: String, max: String)
    case zrem(key: String, values: [String])

    // set
    case sadd(key: String, value: String)

    
    var command: String {
        switch self {
        case .multi: return "MULTI"
        case .exec: return "EXEC"
        case .select: return "SELECT"
        case .lrem: return "LREM"
        case .lpush: return "LPUSH"
        case .lrange: return "LRANGE"
        case .brpoplpush: return "BRPOPLPUSH"
        case .get: return "GET"
        case .set: return "SET"
        case .del: return "DEL"
//        case .mset: return "MSET" FIXME
        case .incr: return "INCR"
        case .zadd: return "ZADD"
        case .sadd: return "SADD"
        case .zrangebyscore: return "ZRANGEBYSCORE"
        case .zrem: return "ZREM"
        }
    }

    var arguments: [RedisData] {
        switch self {
        case .multi:
            return []
        case .exec:
            return []
        case .select(let db):
            return [db.description].redisData()
        case .lrem(let key, let count, let value):
            return [key, count.description, value].redisData()
        case .lpush(let key, let values):
            return values.prepend(key).redisData()
        case .lrange(let key,let start, let stop):
            return [key, start.description, stop.description].redisData()
        case .brpoplpush(let q1, let q2, let timeout):
            return [q1, q2, timeout.description].redisData()
        case .get(let key):
            return [key].redisData()
        case .set(let key, let value):
            return [RedisData(bulk:key),  RedisData.bulkString(value)]
        case .del(let key):
            return [key].redisData()
        case .incr(let key):
            return [key].redisData()
        case .zadd(let queue, let score, let value):
            return [queue, score, value].redisData()
        case .zrangebyscore(let key,let min, let max):
            return [key,min,max].redisData()
        case .zrem(let key, let values):
            return values.prepend(key).redisData()
        case .sadd(let key, let value):
            return [key, value].redisData()
        }
    }
    
}

extension Array where Element == String {
    
    func redisData() -> [RedisData] {
        return self.map { RedisData(bulk: $0) }
    }
}

