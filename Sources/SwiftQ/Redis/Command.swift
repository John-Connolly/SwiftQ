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
    case lrem(key: String, count: Int, value: Foundation.Data)
    case lpush(key: String, values: [Foundation.Data])
    case lrange(key: String, start: Int, stop: Int)
    case brpoplpush(q1: String, q2: String, timeout: Int)
    
    // keys
    case get(key: String)
    case del(key: String)
    case set(key: String, value: BytesRepresentable)
    case mset(EnqueueingBoxes)
    case incr(key: String)
    
    // sorted set
    case zadd(queue: String, score: String, value: String)
    case zrangebyscore(key: String, min: String, max: String)
    case zrem(key: String, values: [BytesRepresentable])
    
    // set
    case sadd(key: String, value: String)
    
    
    var name: String {
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
        case .mset: return "MSET"
        case .incr: return "INCR"
        case .zadd: return "ZADD"
        case .sadd: return "SADD"
        case .zrangebyscore: return "ZRANGEBYSCORE"
        case .zrem: return "ZREM"
        }
    }

    var params2: [RedisData] {
        switch self {
        case .multi: return []
        case .exec:  return []
        case .select(let db):
            return [name, db.description].redisData()
        case .lrem(let key, let count, let value):
            return [name, key, count.description].redisData() + [RedisData.bulkString(value)]
        case .lpush(let key, let values):
            return [name, key].redisData() + values.map(RedisData.bulkString)
        case .lrange(let key, let start, let stop):
            return []
        case .brpoplpush(let q1, let q2, let timeout):
            return [name, q1, q2, timeout.description].redisData()
        case .get(let key):
            return []
        case .del(let key):
            return []
        case .set(let key, let value):
            return []
        case .mset(_):
            return []
        case .incr(let key):
            return []
        case .zadd(let queue, let score, let value):
            return []
        case .zrangebyscore(let key, let min, let max):
            return []
        case .zrem(let key, let values):
            return []
        case .sadd(let key, let value):
            return []
        }
    }
    
}
// MSetSequence
struct EnqueueingBoxes {
    
    private let boxes: [EnqueueingBox]
    
    init(_ boxes: [EnqueueingBox]) {
        self.boxes = boxes
    }
    
    var bytesRepresentable: [BytesRepresentable] {
        return boxes.reduce(into: []) { (args: inout [BytesRepresentable], box) in
            let keyAndValue:[BytesRepresentable] = [box.uuid, box.task]
            args.append(contentsOf: keyAndValue)
        }
    }
    
}


extension Array where Element == String {

    func redisData() -> [RedisData] {
        return self.map { .bulkString(Data($0.utf8)) }
    }
}
