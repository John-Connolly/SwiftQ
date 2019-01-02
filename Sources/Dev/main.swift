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


let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let eventloop = group.next()

let config = Configuration(pollingInterval: 10,
                           enableScheduling: false,
                           concurrency: 4,
                           redisConfig: .development,
                           tasks: [Email.self]
)

let email = Email(email: "jconnolly2")

let resp = Producer.connect(on: eventloop).map { producer in
    producer.enqueue(task: email)
}

//RunLoop.main.run()

let consumer = try Consumer(config)
consumer.run()


//let info = TaskInfo(email)
//let data = try! JSONEncoder().encode(info)
//let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

//print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
