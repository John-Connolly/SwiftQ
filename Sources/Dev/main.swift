//
//  main.swift
//  
//
//  Created by John Connolly on 2018-07-06.
//

import Foundation
import NIO
import SwiftQ

//let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//let eventloop = group.next()
//RunLoop.main.run()


struct TaskInfo<T: Task>: Codable {
    let task: T
    let uuid: String
    let name: String
    var enqueuedAt: Int?
    var retryCount = 0
    var taskType: TaskType
//    var log: Log?

     init(_ task: T) {
        self.name = String(describing: T.self)
        self.task = task
        self.uuid = UUID().uuidString
        self.taskType = .task
    }

}

struct Email: Task {

    let email: String

    func execute(loop: EventLoop) -> EventLoopFuture<()> {
        return loop.newSucceededFuture(result: ())
    }

}


let email = Email(email: "jconnolly")
let info = TaskInfo(email)
let data = try! JSONEncoder().encode(info)
let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)



