//
//  main.swift
//  
//
//  Created by John Connolly on 2018-07-06.
//

import Foundation
import NIO
import SwiftQ


// TODO:
// Figure out how eventloops should be distributed
// Think about backpressure
// Implement stats
// Implement preperations
// Implement monitoring
// Implement heartbeat
// Implement sorted sets
// Implement signal handling for safe shutdown


let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let eventloop = group.next()

let config = Configuration(pollingInterval: 10,
                           enableScheduling: false,
                           concurrency: 4,
                           redisConfig: .development,
                           tasks: [Email.self]
)

let email = Email(email: "jconnolly2")

let emails = (1...100_000).map { _ in
    return email
}

let resp = Producer.connect(on: eventloop).then { producer in
//    producer.enqueue(task: email)
    producer.enqueue(tasks: emails)
}



let consumer = try Consumer(config)
consumer.run()

//AsyncRedis.connect(eventLoop: eventloop).then { redis in
//    redis.pipeLine(message: [
//        .array(Command.incr(key: "test").params2),
//        .array(Command.incr(key: "test").params2),
//        .array(Command.incr(key: "test").params2),
//        .array(Command.incr(key: "test").params2),
//        .array(Command.incr(key: "test").params2),
//        ])
//}
//
RunLoop.main.run()

//let info = TaskInfo(email)
//let data = try! JSONEncoder().encode(info)
//let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

//print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
