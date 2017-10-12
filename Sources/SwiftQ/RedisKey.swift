//
//  RedisKey.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation

enum RedisKey {
    
    case workQ(String)
    case processingQ(String)
    case scheduledQ
    case success(String)
    case failure(String)
    case log
    
    
    var name: String {
        switch self {
        case .workQ(let queue):
            return queue + ":wq"
        case .processingQ(let queue):
            return queue + ":pq"
        case .success(let worker):
            return worker + ":s"
        case .failure(let worker):
            return worker + ":f"
        case .log:
            return "logs"
        case .scheduledQ:
            return  "default:sq"
        }
    }
    
}
