//
//  AsyncWorker.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-28.
//

import Foundation
import NIO

final class AsyncWorker {

    let queue: AsyncReliableQueue
    let decoder: Decoder
    
    let taskEventLoop: EventLoop = {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let eventloop = group.next()
        return eventloop
    }()

    init(queue: AsyncReliableQueue, decoder: Decoder) {
        self.queue = queue
        self.decoder = decoder
    }


    func run() {
        queue.dequeued = { data in
            let task = try! self.decoder.decode(data: data) // FIX ME
            task.execute(loop: self.taskEventLoop).whenComplete {
                self.complete(task: data)
            }
        }

        queue.bdqueue()
    }

    func complete(task: Data) {
        let future = queue.complete(task: task)
        future.whenFailure { error in
            print(error)
        }

//        future.whenSuccess { data in
////            print(data)
//        }


    }
}



