//
//  AsyncWorker.swift
//  SwiftQ
//
//  Created by John Connolly on 2018-12-28.
//

import Foundation
import NIO

final class AsyncWorker {

    let queue: RedisQueue
    let decoder: Decoder


    init(queue: RedisQueue, decoder: Decoder) {
        self.queue = queue
        self.decoder = decoder
    }

    func run() {
        queue.dequeued = { data in
            let task = try! self.decoder.decode(data: data) // FIX ME
            let taskResult = task.execute(loop: self.queue.redis.eventLoop)
            taskResult.whenSuccess {
                self.complete(task: data, isSuccessful: true)
            }
            taskResult.whenFailure { error in
                self.complete(task: data, isSuccessful: false)
            }
        }

        queue.bdqueue()
    }

    func complete(task: Data, isSuccessful: Bool) {
        let future = queue.complete(task: task).then { _ in
            self.queue.recordStats(isSuccessful: isSuccessful)
        }

        future.whenFailure { error in
            print(error)
        }

    }
}



