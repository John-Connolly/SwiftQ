//
//  RedisKey.swift
//  SwiftQ
//
//  Created by John Connolly on 2017-07-04.
//
//

import Foundation

enum RedisKey {

    static let processes = "processes"
    static let statsProcessed = "stats:proccessed"

    static let queue = { name in
        return "queue:" + name
    }

    static let statsProcessedDate = { date in
        return statsProcessed + ":" + date
    }
}


