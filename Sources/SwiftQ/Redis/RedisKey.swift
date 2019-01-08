//
//  RedisKey.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation

enum RedisKey {

    case queue(String)

    var name: String {
        switch self {
        case .queue(let name):
            return "queue:" + name
        }
    }
}


