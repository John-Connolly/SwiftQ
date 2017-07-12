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
    case log(String)
    
    
    var name: String {
        switch self {
        case .workQ(let queue):
            return queue + "_WQ"
        case .processingQ(let queue):
            return queue + "_PQ"
        case .success(let worker):
            return worker + "_S"
        case .failure(let worker):
            return worker + "_F"
        case .log(let worker):
            return worker + "_LOGS"
        case .scheduledQ:
            return  "default_SQ"
        }
    }
    
}
