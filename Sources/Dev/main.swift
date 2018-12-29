//
//  main.swift
//  
//
//  Created by John Connolly on 2018-07-06.
//

import Foundation
import NIO
import SwiftQ


struct TaskInfo<T: Task>: Codable {
    let task: T
    let uuid: String
    let name: String
    var enqueuedAt: Int?
    var retryCount = 0
    var taskType: TaskType
//  var log: Log?

     init(_ task: T) {
        self.name = String(describing: T.self)
        self.task = task
        self.uuid = UUID().uuidString
        self.taskType = .task
    }

}

let config = Configuration(pollingInterval: 10,
                           enableScheduling: false,
                           concurrency: 4,
                           redisConfig: .development,
                           tasks: [Email.self]
)

let email = Email(email: "jconnolly")


//let consumer = try Consumer(config)
//consumer.run()


let group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
let eventloop = group.next()
let redis2 = AsyncRedis.connect(eventLoop: eventloop)
let redis = AsyncRedis.connect(eventLoop: eventloop).and(redis2).map(AsyncReliableQueue.init)


let t = redis.then { queue -> EventLoopFuture<[RedisData]> in
    queue.bdqueue()
    let f = (1...1).map { _ in //1_00_000
        return email
    }
    return queue.enqueue(contentsOf: f)//queue.enqueue(task: email)
    }.map { stuff in
//        switch stuff[0] {
//        case .error(let item): print(item)
//        default:()
//        }
//        print(stuff)
}


//let eventloop2 = group.next()
//let redis3 = AsyncRedis.connect(eventLoop: eventloop2)
//let redis4 = AsyncRedis.connect(eventLoop: eventloop2).and(redis3).map(AsyncReliableQueue.init)
//
//
//let f = redis4.then { queue -> EventLoopFuture<[RedisData]> in
//    queue.bdqueue()
//    let f = (1...1).map { _ in //1_00_000
//        return email
//    }
//    return queue.enqueue(contentsOf: f)//queue.enqueue(task: email)
//    }.map { stuff in
//        //        switch stuff[0] {
//        //        case .error(let item): print(item)
//        //        default:()
//        //        }
//        //        print(stuff)
//}
//
//print(t)



RunLoop.main.run()


//let info = TaskInfo(email)
//let data = try! JSONEncoder().encode(info)
//let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

//print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
