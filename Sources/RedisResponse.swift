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
        return response?.string?.data(using: .utf8)
    }
    
    var int: Int? {
        return response?.int
    }
    
    var array: [Foundation.Data]? {
        return response?
            .array?
            .flatMap { $0?.string?.data(using: .utf8) }
    }
    
}


protocol RedisResponseRepresentable {
    
    var data: Foundation.Data? { get }
    
    var int: Int? { get }
    
    var array: [Foundation.Data]? { get }
    
}
