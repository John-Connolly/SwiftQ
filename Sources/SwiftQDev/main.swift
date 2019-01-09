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
// Figure out how eventloops should be distributed - DONE
// Think about backpressure
// Implement stats -
// Implement preperations - DONE
// Implement monitoring
// Implement heartbeat - DONE
// Implement task failure
// Implement sorted sets
// Implement signal handling for safe shutdown


//let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//let eventloop = group.next()

let config = Configuration(pollingInterval: 1,
                           enableScheduling: false,
                           concurrency: 1,
                           redisConfig: .development,
                           tasks: [Email.self]
)

//let email = Email(email: "jconnolly2")
//
//let emails = (1...10_000).map { _ in
//    return email
//}
//
//let resp = Producer.connect(on: eventloop).then { producer in
////    producer.enqueue(task: email)
//    producer.enqueue(tasks: emails)
//}


let consumer = try Consumer(config)
consumer.run()


//RunLoop.main.run()

//let info = TaskInfo(email)
//let data = try! JSONEncoder().encode(info)
//let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

//print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
