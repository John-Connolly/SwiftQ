//
//  Email.swift
//  Dev
//
//  Created by John Connolly on 2018-12-28.
//

import Foundation
import NIO
import SwiftQ

struct Email: Task {

    let email: String
//    let hello: Hello
//
//    struct Hello: Codable {
//        let int: Int
//    }

    func execute(loop: EventLoop) -> EventLoopFuture<()> {

//        let promise: EventLoopPromise<()> = loop.newPromise()
//        _ = loop.scheduleTask(in: TimeAmount.seconds(1)) {
//            promise.succeed(result: ())
//        }
//        print(email)
        return loop.newSucceededFuture(result: ())
    }

}


struct Deploy: Task {


    let args: [String]

    func execute(loop: EventLoop) -> EventLoopFuture<()> {
        let task = Process()
        task.launchPath = "/bin/bash"//"/Users/johnconnolly/documents/opensource/concorde"//"/root/concorde"
        task.arguments = args
        task.qualityOfService = .userInitiated

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        print(output ?? "Nothing Happened!!")
        task.waitUntilExit()

        return loop.newSucceededFuture(result: ())
    }

}
