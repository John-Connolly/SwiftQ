//
//  RedisResponse.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-06.
//
//

import Foundation
import Redis

struct RedisResponse: RedisResponseRepresentable {
    
    let response: RedisData
    
    var data: Foundation.Data? {
        return response.data
    }
    
    var string: String? {
        return response.string
    }
    
    var int: Int? {
        return response.int
    }
    
    var array: [Foundation.Data]? {
        return response.array?.flatMap { $0.data }
    }
    
}
