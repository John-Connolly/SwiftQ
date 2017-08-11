//
//  VaporRedisResponse.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-06.
//
//

import Foundation
import Redis

struct VaporRedisResponse: RedisResponseRepresentable {
    
    let response: Redis.Data?
    
    var data: Foundation.Data? {
        return response?.bytes.map(Foundation.Data.init(bytes:))
    }
    
    var string: String? {
        return response?.string
    }
    
    var int: Int? {
        return response?.int
    }
    
    var array: [Foundation.Data]? {
        return response?.array?.flatMap { data -> Foundation.Data? in
            return data?.bytes.map(Foundation.Data.init(bytes:))
        }
    }
    
}


protocol RedisResponseRepresentable {
    
    var data: Foundation.Data? { get }
    
    var int: Int? { get }
    
    var string: String? { get }
    
    var array: [Foundation.Data]? { get }
    
}
